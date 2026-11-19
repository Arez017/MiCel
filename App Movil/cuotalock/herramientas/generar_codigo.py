#!/usr/bin/env python3
"""
Generador de códigos CuotaLock v3 (línea de comandos).

Sirve para comparar lo que genera la web de Laravel con lo que espera la app Android.
Mismo algoritmo que app/Services/CodigoBloqueoService.php y Policy.kt:

    código = DDDDD-NNNN-MMMMMM
    DDDDD  = día de vencimiento, en días desde 1970-01-01 (99999 = liberar)
    NNNN   = número de emisión (el celular solo acepta uno MAYOR al último usado)
    MMMMMM = 6 dígitos de HMAC-SHA256(clave[:15], "CL3:<ID>:<DDDDD>:<NNNN>")

La clave es la "clave de vinculación" de 16 caracteres que muestra cada celular
(el último carácter es un verificador). No hay clave global.

Uso:
    python generar_codigo.py A1B2C3D4 ABCD-EFGH-IJKL-MNOx 3 --fecha 2026-12-05
    python generar_codigo.py A1B2C3D4 ABCD-EFGH-IJKL-MNOx 4 --liberar
    python generar_codigo.py --nueva-clave       # genera una clave válida (para pruebas)
    python generar_codigo.py --autotest          # verifica los vectores de prueba
"""
import argparse
import hashlib
import hmac
import re
import secrets
import struct
import sys
from datetime import date

LIBERACION = 99999
MAX_SECUENCIA = 9999
BASE32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
ID_RE = re.compile(r"^[0-9A-F]{8}$")


def verificador(quince: str) -> str:
    return BASE32[sum((i + 1) * BASE32.index(ch) for i, ch in enumerate(quince)) % 32]


def normalizar_clave(clave: str):
    c = re.sub(r"[\s\-]+", "", clave).upper()
    if not re.fullmatch(r"[A-Z2-7]{16}", c):
        return None
    return c if verificador(c[:15]) == c[15] else None


def nueva_clave() -> str:
    quince = "".join(secrets.choice(BASE32) for _ in range(15))
    c = quince + verificador(quince)
    return "-".join(c[i:i + 4] for i in range(0, 16, 4))


def generar(clave: str, device_id: str, dias: int, secuencia: int) -> str:
    c = normalizar_clave(clave)
    if c is None:
        raise SystemExit("Clave de vinculación inválida (16 caracteres A-Z/2-7 con verificador)")
    device_id = device_id.strip().upper()
    if not ID_RE.match(device_id):
        raise SystemExit("El ID del equipo debe tener 8 caracteres hexadecimales (0-9, A-F)")
    if not 0 <= dias <= LIBERACION:
        raise SystemExit(f"Día fuera de rango: {dias}")
    if not 1 <= secuencia <= MAX_SECUENCIA:
        raise SystemExit(f"Número de emisión fuera de rango: {secuencia}")

    msg = f"CL3:{device_id}:{dias}:{secuencia}".encode("utf-8")
    digest = hmac.new(c[:15].encode("utf-8"), msg, hashlib.sha256).digest()
    n = struct.unpack(">I", digest[:4])[0] & 0x7FFFFFFF
    return f"{dias:05d}-{secuencia:04d}-{n % 1_000_000:06d}"


def dias_desde_epoch(fecha: date) -> int:
    return (fecha - date(1970, 1, 1)).days


# Vectores compartidos con CodigoBloqueoServiceTest (PHP). Clave de PRUEBA, no usar en equipos.
CLAVE_PRUEBA = "ABCDEFGHIJKLMNO" + verificador("ABCDEFGHIJKLMNO")
VECTORES = [
    (CLAVE_PRUEBA, "A1B2C3D4", 20792, 1),
    (CLAVE_PRUEBA, "A1B2C3D4", 20792, 2),
    (CLAVE_PRUEBA, "0F0F0F0F", 20792, 1),
    (CLAVE_PRUEBA, "A1B2C3D4", LIBERACION, 7),
]


def autotest(esperados=None) -> int:
    fallos = 0
    for (clave, dev, dias, seq), esperado in zip(VECTORES, esperados or [None] * len(VECTORES)):
        obtenido = generar(clave, dev, dias, seq)
        ok = esperado is None or obtenido == esperado
        fallos += 0 if ok else 1
        print(f"{'OK ' if ok else 'ERR'} {dev} {dias:>5} #{seq} -> {obtenido}")
    assert dias_desde_epoch(date(2026, 12, 5)) == 20792
    return 1 if fallos else 0


ESPERADOS = ["20792-0001-192178", "20792-0002-613452", "20792-0001-033390", "99999-0007-717327"]


def main() -> int:
    p = argparse.ArgumentParser(description="Genera códigos CuotaLock v3")
    p.add_argument("device_id", nargs="?", help="ID del equipo (8 caracteres A-F / 0-9)")
    p.add_argument("clave", nargs="?", help="Clave de vinculación del equipo (16 caracteres)")
    p.add_argument("secuencia", nargs="?", type=int, help="Número de emisión (mayor al último usado)")
    g = p.add_mutually_exclusive_group()
    g.add_argument("--fecha", help="Fecha de vencimiento AAAA-MM-DD")
    g.add_argument("--dias", type=int, help="Días desde 1970-01-01")
    g.add_argument("--liberar", action="store_true", help="Código de liberación del equipo")
    p.add_argument("--nueva-clave", action="store_true", help="Genera una clave de vinculación válida")
    p.add_argument("--autotest", action="store_true", help="Verifica los vectores de prueba")
    a = p.parse_args()

    if a.autotest:
        return autotest(ESPERADOS)
    if a.nueva_clave:
        print(nueva_clave())
        return 0
    if not (a.device_id and a.clave and a.secuencia) or not (a.fecha or a.dias is not None or a.liberar):
        p.error("indica ID, clave, número de emisión y una de: --fecha, --dias, --liberar")

    if a.liberar:
        dias = LIBERACION
    elif a.dias is not None:
        dias = a.dias
    else:
        dias = dias_desde_epoch(date.fromisoformat(a.fecha))

    print(generar(a.clave, a.device_id, dias, a.secuencia))
    return 0


if __name__ == "__main__":
    sys.exit(main())
