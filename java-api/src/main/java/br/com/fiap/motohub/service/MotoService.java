package br.com.fiap.motohub.service;

import br.com.fiap.motohub.model.Moto;
import br.com.fiap.motohub.repository.MotoRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MotoService {

    private final MotoRepository repository;

    public MotoService(MotoRepository repository) {
        this.repository = repository;
    }

    public List<Moto> listarTodas() {
        return repository.findAll();
    }

    public Optional<Moto> buscarPorId(Long id) {
        return repository.findById(id);
    }

    public Moto salvar(Moto moto) {
        return repository.save(moto);
    }

    public void excluir(Long id) {
        repository.deleteById(id);
    }

    public Moto atualizar(Long id, Moto motoAtualizada) {
        Moto existente = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Moto não encontrada com id: " + id));

        motoAtualizada.setId(id);
        return repository.save(motoAtualizada);
    }
}
