package br.com.fiap.motohub.service;

import br.com.fiap.motohub.model.Intencao;
import br.com.fiap.motohub.repository.IntencaoRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class IntencaoService {

    private final IntencaoRepository repository;

    public IntencaoService(IntencaoRepository repository) {
        this.repository = repository;
    }

    public List<Intencao> listarTodas() {
        return repository.findAll();
    }

    public Optional<Intencao> buscarPorId(Long id) {
        return repository.findById(id);
    }

    public Intencao salvar(Intencao intencao) {
        return repository.save(intencao);
    }

    public void excluir(Long id) {
        repository.deleteById(id);
    }

    public Intencao atualizar(Long id, Intencao intencaoAtualizada) {
        Intencao existente = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Intencao não encontrada com id: " + id));

        intencaoAtualizada.setId(id);
        return repository.save(intencaoAtualizada);
    }
}
