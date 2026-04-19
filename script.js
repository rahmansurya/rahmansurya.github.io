const terminal = document.getElementById("terminal");

let loggedIn = false;
let awaitingPassword = false;

function print(text=""){
    terminal.innerHTML += text + "\n";
    terminal.scrollTop = terminal.scrollHeight;
}

function newInput(){
    const line = document.createElement("div");
    line.className = "input-line";

    line.innerHTML = `
        <span class="prompt">${loggedIn ? "root@vir0e5:~#" : "guest@system:~$"}</span>
        <input autofocus />
    `;

    terminal.appendChild(line);
    const input = line.querySelector("input");

    input.focus();

    input.addEventListener("keydown", function(e){
        if(e.key === "Enter"){
            handleCommand(input.value.trim());
            line.remove();
            newInput();
        }
    });
}

/* LOGIN SYSTEM */
function handleCommand(cmd){

    print((loggedIn ? "root" : "guest") + "@vir0e5:~$ " + cmd);

    if(awaitingPassword){
        if(cmd === "toor"){
            loggedIn = true;
            print("ACCESS GRANTED\n");
        } else {
            print("ACCESS DENIED\n");
        }
        awaitingPassword = false;
        return;
    }

    switch(cmd){

        case "login root":
            print("password:");
            awaitingPassword = true;
        break;

        case "help":
            print(`
help
login root
whoami
scan
hack target.com
ip
game
clear
`);
        break;

        case "whoami":
            print(loggedIn ? "root" : "guest");
        break;

        case "ip":
            fetch("https://api.ipify.org?format=json")
            .then(res=>res.json())
            .then(data=>{
                print("Your IP: " + data.ip);
            });
        break;

        case "scan":
            fakeProgress("Scanning system...");
        break;

        case "hack target.com":
            fakeProgress("Bruteforcing target.com...");
        break;

        case "game":
            startGame();
        break;

        case "clear":
            terminal.innerHTML="";
        break;

        default:
            print("command not found");
    }
}

/* FAKE PROGRESS */
function fakeProgress(text){
    let i = 0;
    let interval = setInterval(()=>{
        print(text + " " + i + "%");
        i += Math.floor(Math.random()*20);

        if(i >= 100){
            clearInterval(interval);
            print("DONE ✔\n");
        }
    },200);
}

/* MINI GAME (guess number) */
function startGame(){
    let number = Math.floor(Math.random()*10)+1;
    print("Guess number (1-10)");

    const gameInput = document.createElement("input");
    terminal.appendChild(gameInput);
    gameInput.focus();

    gameInput.addEventListener("keydown", function(e){
        if(e.key === "Enter"){
            let guess = parseInt(gameInput.value);

            if(guess === number){
                print("Correct! 🎉");
            } else {
                print("Wrong! number was " + number);
            }

            gameInput.remove();
            newInput();
        }
    });
}

/* BOOT */
async function boot(){
    const bootText = [
        "Booting old CRT terminal...",
        "Loading modules...",
        "Establishing secure link...",
        "System ready.\n",
        "Type 'help'"
    ];

    for(let line of bootText){
        print(line);
        await new Promise(r=>setTimeout(r,300));
    }

    newInput();
}

boot();
