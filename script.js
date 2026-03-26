function runScript() {
    document.getElementById('output').innerHTML = `
        <h2>✅ BERHASIL!</h2>
        <p><strong>Waktu:</strong> ${new Date().toLocaleString('id-ID')}</p>
        <p><strong>Hosting:</strong> GitHub Pages + Raw URL</p>
        <p><strong>URL Raw JS:</strong> https://raw.githubusercontent.com/rahmansurya/tersesat.github.io/main/script.js</p>
    `;
    
    // Effect animasi
    document.body.style.animation = 'pulse 1s infinite';
}

// CSS animation via JS
const style = document.createElement('style');
style.textContent = `
    @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.05); }
        100% { transform: scale(1); }
    }
`;
document.head.appendChild(style);
