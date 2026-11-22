package com.example.ordermanager;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DemoFalloTest {

    @Test
    void fallaAProposito() {
        assertEquals(1, 2, "Fallo intencional para demostrar el bloqueo del pipeline");
    }
}