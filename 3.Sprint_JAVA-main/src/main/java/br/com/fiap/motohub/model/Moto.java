package br.com.fiap.motohub.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Moto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String modelo;
    private String marca;
    private int ano;

    @Enumerated(EnumType.STRING)
    private TipoUso tipoUso; // VENDA ou ALUGUEL

    @Column(nullable = false)
    private Boolean disponivel = true;
}
