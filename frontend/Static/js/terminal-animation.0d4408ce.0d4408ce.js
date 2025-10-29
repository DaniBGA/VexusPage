/**
 * Animación de Terminal - Simula código escribiéndose
 */

class TerminalAnimation {
    constructor() {
        this.codeElement = document.getElementById('terminal-code');
        this.outputElement = document.getElementById('terminal-output');
        this.currentCommandIndex = 0;
        this.currentCharIndex = 0;
        this.isTyping = false;

        // Comandos y respuestas que se van a mostrar
        this.commands = [
            {
                command: 'npm run build',
                delay: 1000,
                output: [
                    { text: '> vexus@1.0.0 build', type: 'info' },
                    { text: '> webpack --mode production', type: 'info' },
                    { text: '', type: 'normal' },
                    { text: 'Hash: a1b2c3d4e5f6', type: 'normal' },
                    { text: 'Version: webpack 5.88.0', type: 'normal' },
                    { text: 'Time: 2341ms', type: 'normal' },
                    { text: 'Built at: 09/22/2024 12:30:45 PM', type: 'normal' },
                    { text: '✓ compiled successfully', type: 'success' }
                ]
            },
            {
                command: 'git status',
                delay: 2000,
                output: [
                    { text: 'On branch main', type: 'info' },
                    { text: 'Your branch is up to date with \'origin/main\'.', type: 'normal' },
                    { text: '', type: 'normal' },
                    { text: 'nothing to commit, working tree clean', type: 'success' }
                ]
            },
            {
                command: 'node server.js',
                delay: 2000,
                output: [
                    { text: 'Server starting...', type: 'info' },
                    { text: '✓ Database connected', type: 'success' },
                    { text: '✓ Routes loaded', type: 'success' },
                    { text: '🚀 Server running on port 3000', type: 'success' }
                ]
            },
            {
                command: 'npm test',
                delay: 2500,
                output: [
                    { text: '> vexus@1.0.0 test', type: 'info' },
                    { text: '> jest --coverage', type: 'info' },
                    { text: '', type: 'normal' },
                    { text: 'PASS  tests/unit/auth.test.js', type: 'success' },
                    { text: 'PASS  tests/unit/api.test.js', type: 'success' },
                    { text: 'PASS  tests/integration/routes.test.js', type: 'success' },
                    { text: '', type: 'normal' },
                    { text: 'Tests: 24 passed, 24 total', type: 'success' },
                    { text: 'Coverage: 94.5%', type: 'success' }
                ]
            }
        ];

        this.typingSpeed = 80;
        this.outputDelay = 100;
    }

    init() {
        // Pequeño delay antes de empezar
        setTimeout(() => this.startAnimation(), 1500);
    }

    startAnimation() {
        this.typeCommand();
    }

    typeCommand() {
        if (this.currentCommandIndex >= this.commands.length) {
            // Reiniciar el ciclo después de mostrar todos los comandos
            setTimeout(() => {
                this.reset();
                this.startAnimation();
            }, 5000);
            return;
        }

        const currentCommand = this.commands[this.currentCommandIndex];
        this.isTyping = true;

        const typeInterval = setInterval(() => {
            if (this.currentCharIndex < currentCommand.command.length) {
                const char = currentCommand.command[this.currentCharIndex];
                this.codeElement.textContent += char;
                this.currentCharIndex++;
            } else {
                clearInterval(typeInterval);
                this.isTyping = false;
                this.currentCharIndex = 0;

                // Después de terminar de escribir, mostrar output
                setTimeout(() => {
                    this.showOutput(currentCommand);
                }, 300);
            }
        }, this.typingSpeed);
    }

    showOutput(command) {
        let lineIndex = 0;

        const showNextLine = () => {
            if (lineIndex < command.output.length) {
                const line = command.output[lineIndex];
                const lineElement = document.createElement('div');
                lineElement.className = `terminal-output-line ${line.type}`;
                lineElement.textContent = line.text || ' ';
                this.outputElement.appendChild(lineElement);
                lineIndex++;

                setTimeout(showNextLine, this.outputDelay);
            } else {
                // Después de mostrar todo el output, esperar y limpiar
                setTimeout(() => {
                    this.clearTerminal();
                    this.currentCommandIndex++;
                    this.typeCommand();
                }, command.delay);
            }
        };

        showNextLine();
    }

    clearTerminal() {
        this.codeElement.textContent = '';
        this.outputElement.innerHTML = '';
    }

    reset() {
        this.currentCommandIndex = 0;
        this.currentCharIndex = 0;
        this.clearTerminal();
    }
}

// Inicializar la animación cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    const terminalCode = document.getElementById('terminal-code');

    if (terminalCode) {
        const terminalAnimation = new TerminalAnimation();
        terminalAnimation.init();
    }
});
