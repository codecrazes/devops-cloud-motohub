package br.com.fiap.motohub.repository;

import br.com.fiap.motohub.model.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {
}
