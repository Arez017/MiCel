<?php

// app/Services/CodigoDesbloqueo.php  (Laravel / MiCel)
// Mismo algoritmo que Policy.kt y generar_codigo.py.
// Guarda la clave en .env:  CUOTALOCK_SECRET=CAMBIA-ESTA-CLAVE-SECRETA
// y en config/micel.php:    'lock_secret' => env('CUOTALOCK_SECRET'),

namespace App\Services;

use Carbon\CarbonInterface;

class CodigoDesbloqueo
{
    private const FOREVER = 99999;

    public static function para(string $deviceId, CarbonInterface $vence): string
    {
        $dias = intdiv(gmmktime(0, 0, 0, (int) $vence->month, (int) $vence->day, (int) $vence->year), 86400);
        return self::generar($deviceId, $dias);
    }

    public static function liberar(string $deviceId): string
    {
        return self::generar($deviceId, self::FOREVER);
    }

    private static function generar(string $deviceId, int $dias): string
    {
        $h = hash_hmac('sha256', strtoupper($deviceId) . ':' . $dias, config('micel.lock_secret'), true);
        $n = unpack('N', substr($h, 0, 4))[1] & 0x7fffffff;
        return sprintf('%05d-%06d', $dias, $n % 1000000);
    }
}
