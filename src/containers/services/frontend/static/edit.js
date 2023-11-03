const TASK_NAME = document.querySelector(".overlay-panel h1").textContent;
const TASK_TEXTAREA = document.querySelector(".task-textarea");

console.log({name: TASK_NAME, text: TASK_TEXTAREA.innerText});

async function editTask() {
    // We replace every double newline with a single one due to contentEditable div being shit
    const taskText = TASK_TEXTAREA.innerText.trim().replaceAll("\n\n", "\n");
    if (taskText.trim() === "") {
        console.log("Can't add empty note!");
        return;
    }

    console.log("Editing '" + TASK_NAME + "' with new value '" + taskText + "'");

    const response = await fetch("/api/editTask", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            taskName: TASK_NAME,
            taskText: taskText
        })
    });

    const data = await response.json();
    console.log(data);

    if (data.success) {
        console.log("Success!!!");
        window.location.href = "/";
    }
}

document.querySelector(".overlay-panel button").addEventListener("click", editTask);