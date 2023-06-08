// Bắt sự kiện click trên nút Confirm
document
  .getElementById("confirmBtn")
  .addEventListener("click", function (event) {
    var depositID = document.getElementById("depositID").value;
    var fullname = document.getElementById("fullname").value;
    var deposit = document.getElementById("deposit").value;

    // Kiểm tra giá trị trường depositID
    if (depositID.trim() === "") {
      event.preventDefault(); // Ngăn chặn hành động mặc định của nút submit
      alert("Deposit ID"); // Hiển thị thông báo lỗi
      return;
    }

    // Kiểm tra giá trị trường fullname
    if (fullname.trim() === "") {
      event.preventDefault(); // Ngăn chặn hành động mặc định của nút submit
      alert("Vui lòng nhập họ và tên"); // Hiển thị thông báo lỗi
      return;
    }

    // Kiểm tra giá trị trường deposit
    if (deposit.trim() === "" || isNaN(deposit) || deposit <= 0) {
      event.preventDefault(); // Ngăn chặn hành động mặc định của nút submit
      alert("Vui lòng nhập một giá trị hợp lệ cho Withdraw"); // Hiển thị thông báo lỗi
      return;
    }

    var result = confirm("Confirm withdraw?"); // Hiển thị thông báo confirm
    if (!result) {
      event.preventDefault(); // Ngăn chặn hành động mặc định của nút submit
    }
  });
