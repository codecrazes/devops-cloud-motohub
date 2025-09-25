package br.com.fiap.motohub.controller;

import br.com.fiap.motohub.model.Cliente;
import br.com.fiap.motohub.service.ClienteService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/clientes")
public class ClienteController {

    private final ClienteService service;

    public ClienteController(ClienteService service) {
        this.service = service;
    }

    @GetMapping
    public String listarClientes(Model model) {
        model.addAttribute("clientes", service.listarTodos());
        model.addAttribute("cliente", new Cliente());
        return "clientes";
    }

    @PostMapping
    public String salvarOuEditarCliente(@ModelAttribute Cliente cliente) {
        service.salvar(cliente);
        return "redirect:/clientes";
    }

    @GetMapping("/{id}")
    public String carregarCliente(@PathVariable Long id, Model model) {
        Cliente cliente = service.buscarPorId(id).orElseThrow();
        model.addAttribute("clientes", service.listarTodos());
        model.addAttribute("cliente", cliente);
        return "clientes";
    }

    @PostMapping("/{id}/delete")
    public String excluirCliente(@PathVariable Long id) {
        service.excluir(id);
        return "redirect:/clientes";
    }
}
