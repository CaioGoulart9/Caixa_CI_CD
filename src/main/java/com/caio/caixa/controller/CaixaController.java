package com.caio.caixa.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.caio.caixa.model.Caixa;
import com.caio.caixa.service.CaixaService;

@RestController
@RequestMapping("/caixa")
public class CaixaController {

    private final CaixaService caixaService;

    public CaixaController(CaixaService caixaService) {
        this.caixaService = caixaService;
    }

    @GetMapping
    public List<Caixa> listar() {
        return caixaService.listar();
    }
}
