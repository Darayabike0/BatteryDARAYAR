document.addEventListener("DOMContentLoaded", () => {
  // ====== Table Sorting ======
  const table = document.querySelector("table");
  const headers = table.querySelectorAll("th");

  headers.forEach((header, index) => {
    header.addEventListener("click", () => {
      sortTable(table, index);
    });
  });

  function sortTable(table, colIndex) {
    const rows = Array.from(table.rows).slice(1);
    const sorted = rows.sort((a, b) => {
      const valA = a.cells[colIndex].innerText.toLowerCase();
      const valB = b.cells[colIndex].innerText.toLowerCase();
      return valA.localeCompare(valB);
    });
    sorted.forEach(row => table.appendChild(row));
  }

  // ====== Section Toggle ======
  document.querySelectorAll("section h2").forEach(h2 => {
    h2.style.cursor = "pointer";
    h2.addEventListener("click", () => {
      const content = h2.nextElementSibling;
      content.style.display =
        content.style.display === "none" ? "block" : "none";
    });
  });

  // ====== Dark Mode Toggle ======
  const footer = document.querySelector("footer");
  const toggleBtn = document.createElement("button");
  toggleBtn.innerText = "Toggle Dark Mode";
  toggleBtn.style.marginTop = "10px";
  footer.appendChild(toggleBtn);

  toggleBtn.addEventListener("click", () => {
    document.body.classList.toggle("dark-mode");
  });

  // ====== Highlight on Hover ======
  table.querySelectorAll("td").forEach(cell => {
    cell.addEventListener("mouseenter", () => {
      cell.style.backgroundColor = "#ffeaa7";
    });
    cell.addEventListener("mouseleave", () => {
      cell.style.backgroundColor = "";
    });
  });
});