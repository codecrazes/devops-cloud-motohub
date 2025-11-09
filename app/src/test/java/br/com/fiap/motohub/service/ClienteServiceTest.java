package br.com.fiap.motohub.service;

import br.com.fiap.motohub.model.Cliente;
import br.com.fiap.motohub.repository.ClienteRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ClienteServiceTest {

    @Mock
    private ClienteRepository repository;

    @InjectMocks
    private ClienteService service;

    // 1 — LISTAR TODOS
    @Test
    void deveListarTodosOsClientes() {
        // Arrange
        Cliente c1 = new Cliente();
        Cliente c2 = new Cliente();
        when(repository.findAll()).thenReturn(List.of(c1, c2));

        // Act
        var lista = service.listarTodos();

        // Assert
        assertNotNull(lista);
        assertEquals(2, lista.size());
        verify(repository, times(1)).findAll();
    }

    // 2 — BUSCAR POR ID
    @Test
    void deveBuscarClientePorIdComSucesso() {
        // Arrange
        Cliente cliente = new Cliente();
        cliente.setId(1L);
        cliente.setNome("Caroline");

        when(repository.findById(1L)).thenReturn(Optional.of(cliente));

        // Act
        Optional<Cliente> resultado = service.buscarPorId(1L);

        // Assert
        assertTrue(resultado.isPresent());
        assertEquals("Caroline", resultado.get().getNome());
        verify(repository).findById(1L);
    }

    // 3 — BUSCAR POR ID (NÃO ENCONTRADO)
    @Test
    void deveRetornarEmptyQuandoClienteNaoEncontradoPorId() {
        // Arrange
        when(repository.findById(99L)).thenReturn(Optional.empty());

        // Act
        Optional<Cliente> resultado = service.buscarPorId(99L);

        // Assert
        assertTrue(resultado.isEmpty());
        verify(repository).findById(99L);
    }


    // 4 — SALVAR CLIENTE
    @Test
    void deveSalvarClienteCorretamente() {
        // Arrange
        Cliente novo = new Cliente();
        novo.setNome("Caroline");

        Cliente salvo = new Cliente();
        salvo.setId(1L);
        salvo.setNome("Caroline");

        when(repository.save(novo)).thenReturn(salvo);

        // Act
        Cliente resultado = service.salvar(novo);

        // Assert
        assertNotNull(resultado);
        assertEquals(1L, resultado.getId());
        assertEquals("Caroline", resultado.getNome());
        verify(repository).save(novo);
    }

    // 5 — EXCLUIR CLIENTE
    @Test
    void deveExcluirClientePeloId() {
        // Arrange
        Long id = 10L;

        // Act
        service.excluir(id);

        // Assert
        verify(repository).deleteById(10L);
    }

    // 6 — ATUALIZAR CLIENTE
    @Test
    void deveAtualizarClienteComSucesso() {
        // Arrange
        Cliente existente = new Cliente();
        existente.setId(1L);
        existente.setNome("Antigo");
        existente.setEmail("antigo@email.com");
        existente.setTelefone("1111");

        Cliente atualizado = new Cliente();
        atualizado.setNome("Novo");
        atualizado.setEmail("novo@email.com");
        atualizado.setTelefone("9999");

        when(repository.findById(1L)).thenReturn(Optional.of(existente));
        when(repository.save(existente)).thenReturn(existente);

        // Act
        Cliente resultado = service.atualizar(1L, atualizado);

        // Assert
        assertEquals("Novo", resultado.getNome());
        assertEquals("novo@email.com", resultado.getEmail());
        assertEquals("9999", resultado.getTelefone());
        verify(repository).save(existente);
    }
    
    // 7 — ATUALIZAR CLIENTE INEXISTENTE
    
    @Test
    void deveLancarExcecaoAoAtualizarClienteInexistente() {
        // Arrange
        when(repository.findById(100L)).thenReturn(Optional.empty());

        Cliente atualizado = new Cliente();
        atualizado.setNome("Teste");

        // Act + Assert
        RuntimeException ex = assertThrows(
            RuntimeException.class,
            () -> service.atualizar(100L, atualizado)
        );

        assertTrue(ex.getMessage().contains("Cliente não encontrado"));
        verify(repository, never()).save(any());
    }
}
