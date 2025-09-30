package br.com.fiap.motohub.repository;

import br.com.fiap.motohub.model.Moto;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MotoRepository extends JpaRepository<Moto, Long> {
}
