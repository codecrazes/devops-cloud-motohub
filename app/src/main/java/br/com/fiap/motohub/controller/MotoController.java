package br.com.fiap.motohub.controller;

import br.com.fiap.motohub.model.Moto;
import br.com.fiap.motohub.repository.MotoRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/motos")
public class MotoController {

    private final MotoRepository motoRepository;

    public MotoController(MotoRepository motoRepository) {
        this.motoRepository = motoRepository;
    }

    @GetMapping
    public String listarMotos(Model model) {
        model.addAttribute("motos", motoRepository.findAll());
        model.addAttribute("moto", new Moto());
        return "motos";
    }

    @PostMapping
    public String salvarOuEditarMoto(@ModelAttribute Moto moto) {
        motoRepository.save(moto);
        return "redirect:/motos";
    }

    @GetMapping("/{id}")
    public String carregarMoto(@PathVariable Long id, Model model) {
        Moto moto = motoRepository.findById(id).orElseThrow();
        model.addAttribute("motos", motoRepository.findAll());
        model.addAttribute("moto", moto);
        return "motos";
    }

    @PostMapping("/{id}/delete")
    public String excluirMoto(@PathVariable Long id) {
        motoRepository.deleteById(id);
        return "redirect:/motos";
    }
}
