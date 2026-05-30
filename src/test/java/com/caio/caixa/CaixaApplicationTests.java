package com.caio.caixa;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import com.caio.caixa.model.Caixa;
import com.caio.caixa.service.CaixaService;

@SpringBootTest
class CaixaApplicationTests {

	@Test
	void contextLoads() {
	}

	@Test
	void deveListarCaixas() {
		CaixaService service = new CaixaService();
		List<Caixa> resultado = service.listar();

		assertFalse(resultado.isEmpty());
		assertEquals("Teste", resultado.get(0).produtoName());
		assertEquals(19.90, resultado.get(0).valorProduto());
	}
}
