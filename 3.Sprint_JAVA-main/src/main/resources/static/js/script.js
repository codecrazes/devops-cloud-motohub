document.addEventListener("DOMContentLoaded", () => {
    console.log("Motohub carregado");

    const buttons = document.querySelectorAll("button");

    buttons.forEach(btn => {
        btn.addEventListener("mouseover", () => {
            btn.style.opacity = "0.9";
        });

        btn.addEventListener("mouseout", () => {
            btn.style.opacity = "1";
        });
    });
});
