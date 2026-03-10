<?php
return [
    'name'            => 'InvestPro',
    'url'             => getenv('APP_URL') ?: 'http://localhost',
    'env'             => getenv('APP_ENV') ?: 'production',
    'debug'           => (bool)(getenv('APP_DEBUG') ?: false),
    'timezone'        => 'UTC',
    'currency'        => 'USD',
    'currencies'      => ['USD', 'EUR'],
    'session_name'    => 'investpro_session',
    'session_lifetime'=> 7200,
    'csrf_token_name' => '_csrf_token',
];
