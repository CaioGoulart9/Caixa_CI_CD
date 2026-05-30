package com.caio.caixa.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.caio.caixa.model.Caixa;

@Service
public class CaixaService {

    public List<Caixa> listar() {
        List<Caixa> caixas = new ArrayList<>();
        caixas.add(new Caixa("Teste", 19.90));
        return caixas;
    }
}
