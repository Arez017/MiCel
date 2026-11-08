#!/usr/bin/env python3
"""
Genera el código de pago/desbloqueo para un equipo CuotaLock.

Uso:
  python generar_codigo.py ID_EQUIPO 2026-12-05   # nuevo vencimiento en esa fecha
  python generar_codigo.py ID_EQUIPO +30          # vence dentro de 30 días
  python generar_codigo.py ID_EQUIPO liberar      # cuotas liquidadas (libera el equipo)

La SECRET debe ser IDÉNTICA a la de Policy.kt.
"""
import datetime
import hashlib
import hmac
import sys

SECRET = b"CAMBIA-ESTA-CLAVE-SECRETA"
FOREVER = 99999
EPOCH = datetime.date(1970, 1, 1)


def codigo(device_id: str, days: int) -> str:
    h = hmac.new(SECRET, f"{device_id.upper()}:{days}".encode(), hashlib.sha256).digest()
    n = int.from_bytes(h[:4], "big") & 0x7FFFFFFF
    return f"{days:05d}-{n % 1_000_000:06d}"


def main() -> None:
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    device_id, cuando = sys.argv[1], sys.argv[2]

    if cuando.lower() == "liberar":
        print(codigo(device_id, FOREVER))
        return
    if cuando.startswith("+"):
        fecha = datetime.date.today() + datetime.timedelta(days=int(cuando[1:]))
    else:
        fecha = datetime.date.fromisoformat(cuando)

    days = (fecha - EPOCH).days
    print(f"Equipo {device_id.upper()} · vence el {fecha.isoformat()}")
    print(f"CÓDIGO: {codigo(device_id, days)}")


if __name__ == "__main__":
    main()
