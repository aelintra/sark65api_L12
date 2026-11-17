<?php

it('returns json 401 for api guest without Accept header', function () {
    $response = $this->get('/api/auth/whoami');

    $response->assertStatus(401);
    $response->assertJsonStructure(['message']);
});

it('returns json 401 for api guest with Accept application/json', function () {
    $response = $this->getJson('/api/auth/whoami');

    $response->assertStatus(401);
    $response->assertJsonStructure(['message']);
});
