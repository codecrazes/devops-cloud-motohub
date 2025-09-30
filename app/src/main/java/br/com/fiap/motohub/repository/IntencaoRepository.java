package br.com.fiap.motohub.repository;

import br.com.fiap.motohub.model.Intencao;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IntencaoRepository extends JpaRepository<Intencao, Long> {
}
