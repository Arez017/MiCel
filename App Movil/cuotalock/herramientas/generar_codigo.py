#!/usr/bin/env python3
"""
Generador de códigos CuotaLock (línea de comandos).

Sirve para comparar lo que genera la web de Laravel con lo que espera la app Android.
Mismo algoritmo que app/Services/CodigoBloqueoService.php y Policy.kt:

    código = DDDDD-MMMMMM
    DDDDD  = día de vencimiento, en días desde 1970-01-01 (99999 = liberar)
    MMMMMM = 6 dígitos de HMAC-SHA256(secret, "<ID>:<DDDDD>")

Uso:
    export CUOTALOCK_SECRET="tu-clave"          # Windows (PowerShell): $env:CUOTALOCK_SECRET="tu-clave"
    python generar_codigo.py A1B2C3D4 --fecha 2026-12-05
    python generar_codigo.py A1B2C3D4 --dias 20792
    python generar_codigo.py A1B2C3D4 --liberar
    python generar_codigo.py --autotest          # verifica los vectores de prueba
"""
import argparse
import hashlib
import hmac
import os
import re
import struct
import sys
from datetime import date

LIBERACION = 99999
ID_RE = re.compile(r"^[0-9A-F]{8}$")


def generar(secret: str, device_id: str, dias: int) -> str:
    if not secret:
        raise SystemExit("Falta la clave: define la variable de entorno CUOTALOCK_SECRET")
    device_id = device_id.strip().upper()
    if not ID_RE.match(device_id):
        raise SystemExit("El ID del equipo debe tener 8 caracteres hexadecimales (0-9, A-F)")
    if not 0 <= dias <= LIBERACION:
        raise SystemExit(f"Día fuera de rango: {dias}")

    digest = hmac.new(secret.encode("utf-8"), f"{device_id}:{dias}".encode("utf-8"), hashlib.sha256).digest()
    n = struct.unpack(">I", digest[:4])[0] & 0x7FFFFFFF
    return f"{dias:05d}-{n % 1_000_000:06d}"


def dias_desde_epoch(fecha: date) -> int:
    return (fecha - date(1970, 1, 1)).days


def autotest() -> int:
    secret = "CAMBIA-ESTA-CLAVE-SECRETA"
    casos = [
        ("A1B2C3D4", 20792, "20792-188885"),
        ("A1B2C3D4", 20790, "20790-328725"),
        ("A1B2C3D4", 20800, "20800-955529"),
        ("A1B2C3D4", LIBERACION, "99999-679956"),
        ("0F0F0F0F", 20792, "20792-037945"),
    ]
    fallos = 0
    for dev, dias, esperado in casos:
        obtenido = generar(secret, dev, dias)
        ok = obtenido == esperado
        fallos += 0 if ok else 1
        print(f"{'OK ' if ok else 'ERR'} {dev} {dias:>5} -> {obtenido} (esperado {esperado})")
    assert dias_desde_epoch(date(2026, 12, 5)) == 20792
    return 1 if fallos else 0


def main() -> int:
    p = argparse.ArgumentParser(description="Genera códigos CuotaLock")
    p.add_argument("device_id", nargs="?", help="ID del equipo (8 caracteres A-F / 0-9)")
    g = p.add_mutually_exclusive_group()
    g.add_argument("--fecha", help="Fecha de vencimiento AAAA-MM-DD")
    g.add_argument("--dias", type=int, help="Días desde 1970-01-01")
    g.add_argument("--liberar", action="store_true", help="Código de liberación del equipo")
    p.add_argument("--autotest", action="store_true", help="Verifica los vectores de prueba")
    a = p.parse_args()

    if a.autotest:
        return autotest()

    if not a.device_id or not (a.fecha or a.dias is not None or a.liberar):
        p.error("indica el ID del equipo y una de: --fecha, --dias, --liberar")

    secret = os.environ.get("CUOTALOCK_SECRET", "")
    if a.liberar:
        dias = LIBERACION
    elif a.dias is not None:
        dias = a.dias
    else:
        dias = dias_desde_epoch(date.fromisoformat(a.fecha))

    print(generar(secret, a.device_id, dias))
    return 0


if __name__ == "__main__":
    sys.exit(main())
