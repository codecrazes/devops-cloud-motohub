package br.com.fiap.motohub.controller;

import br.com.fiap.motohub.model.Usuario;
import br.com.fiap.motohub.service.UsuarioService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/usuarios")
public class UsuarioController {

    private final UsuarioService service;

    public UsuarioController(UsuarioService service) {
        this.service = service;
    }

    @GetMapping
    public String listarUsuarios(Model model) {
        List<Usuario> usuarios = service.listarTodos();
        model.addAttribute("usuarios", usuarios);
        return "usuarios";                               
    }
}
