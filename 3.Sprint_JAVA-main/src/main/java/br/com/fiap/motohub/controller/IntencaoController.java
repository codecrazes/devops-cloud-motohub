package br.com.fiap.motohub.controller;

import br.com.fiap.motohub.model.Cliente;
import br.com.fiap.motohub.model.Intencao;
import br.com.fiap.motohub.model.Moto;
import br.com.fiap.motohub.model.TipoUso;
import br.com.fiap.motohub.repository.ClienteRepository;
import br.com.fiap.motohub.repository.IntencaoRepository;
import br.com.fiap.motohub.repository.MotoRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/intencoes")
public class IntencaoController {

    private final IntencaoRepository intencaoRepository;
    private final ClienteRepository clienteRepository;
    private final MotoRepository motoRepository;

    public IntencaoController(IntencaoRepository intencaoRepository,
                              ClienteRepository clienteRepository,
                              MotoRepository motoRepository) {
        this.intencaoRepository = intencaoRepository;
        this.clienteRepository = clienteRepository;
        this.motoRepository = motoRepository;
    }

    @GetMapping
    public String listarIntencoes(Model model) {
        model.addAttribute("intencoes", intencaoRepository.findAll());
        model.addAttribute("clientes", clienteRepository.findAll());
        model.addAttribute("motos", motoRepository.findAll());
        model.addAttribute("intencao", new Intencao()); 
        return "intencoes";
    }

    @GetMapping("/{id}")
    public String editarIntencao(@PathVariable Long id, Model model) {
        Intencao intencao = intencaoRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Id inválido: " + id));

        model.addAttribute("intencao", intencao);
        model.addAttribute("intencoes", intencaoRepository.findAll());
        model.addAttribute("clientes", clienteRepository.findAll());
        model.addAttribute("motos", motoRepository.findAll());
        return "intencoes"; 
    }

    @PostMapping
    public String salvarOuEditarIntencao(
            @RequestParam(required = false) Long id,
            @RequestParam Long clienteId,
            @RequestParam Long motoId,
            @RequestParam String tipo) {

        Intencao intencao = (id != null) ? intencaoRepository.findById(id).orElse(new Intencao()) : new Intencao();

        Cliente cliente = clienteRepository.findById(clienteId)
                .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado"));
        Moto moto = motoRepository.findById(motoId)
                .orElseThrow(() -> new IllegalArgumentException("Moto não encontrada"));

        intencao.setCliente(cliente);
        intencao.setMoto(moto);
        intencao.setTipo(TipoUso.valueOf(tipo));

        intencaoRepository.save(intencao);

        return "redirect:/intencoes";
    }

    @PostMapping("/{id}/delete")
    public String deletarIntencao(@PathVariable Long id) {
        intencaoRepository.deleteById(id);
        return "redirect:/intencoes";
    }
}
