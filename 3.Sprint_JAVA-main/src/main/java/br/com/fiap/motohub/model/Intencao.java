package br.com.fiap.motohub.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Intencao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;

    @ManyToOne
    @JoinColumn(name = "moto_id")
    private Moto moto;

    @Enumerated(EnumType.STRING)
    private TipoUso tipo; // VENDA ou ALUGUEL
}
