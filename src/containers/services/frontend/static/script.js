function generateTaskElement(name, text) {
    const taskContainer = document.querySelector(".tasks");
    const template = document.getElementById("task-template");

    const clone = template.content.cloneNode(true);

    // Add remove button event listener
    let taskRemoveButton = clone.querySelector(".task-remove-button");
    taskRemoveButton.addEventListener("click", removeTask);
    
    // Add edit button href
    let taskEditButtons = clone.querySelectorAll("a");
    taskEditButtons.forEach((el) => {
        if (el.href !== "") return;

        el.href = "/edit/" + encodeURIComponent(name);
    });

    // Add name and text
    let taskNameElement = clone.querySelector(".task-name");
    let taskContentElement = clone.querySelector(".task-content");

    taskNameElement.textContent = name;
    taskContentElement.textContent = text;

    taskContainer.appendChild(clone);
}

async function addTask() {
    const taskInput = document.getElementById("add-task-input");
    const taskText = taskInput.value;
    if (taskText.trim() === "") {
        console.log("Can't add empty note!");
        return;
    }

    console.log("Adding '" + taskText + "'");

    const response = await fetch("/api/addTask", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            task: taskText
        })
    });

    const data = await response.json();
    console.log(data);

    if (data.success) {
        generateTaskElement(data.task.name, data.task.text);

        taskInput.value = "";
    }
}

async function removeTask(el) {
    const taskItem = el.target.closest(".task-item");
    const taskName = taskItem.querySelector(".task-name").textContent;

    const response = await fetch("/api/removeTask", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            taskName: taskName
        })
    });

    const data = await response.json();
    console.log(data);

    if (data.success) {
        taskItem.remove();
    }
}

async function createAllTasks() {
    const response = await fetch("/api/tasks", {
        method: "GET"
    });

    const data = await response.json();
    console.log(data);

    if (data.success) {
        data.tasks.forEach(task => {
            generateTaskElement(task.name, task.text);
        });
    }
}

document.querySelector(".add-task-field button").addEventListener("click", addTask);
document.querySelector(".add-task-field").addEventListener("keypress", async function(e) {
    if (e.key === "Enter") {
        addTask();
    }
});

createAllTasks();