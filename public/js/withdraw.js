// Bắt sự kiện click trên nút Confirm
var check = true
var nameRegex =
    /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềểếỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ\s\W|_]+$/;
document
    .getElementById("confirmBtn")
    .addEventListener("click", function (event) {
        var depositID = document.getElementById("depositID").value;
        var fullname = document.getElementById("fullname").value;
        check = true
        // Kiểm tra giá trị trường depositID
        if (depositID.trim() === "") {
            event.preventDefault(); // Ngăn chặn hành động mặc định của nút submit
            alert("Chưa nhập Deposit ID"); // Hiển thị thông báo lỗi
            check = false
            return;
        }

        // Kiểm tra giá trị trường fullname
        if (fullname.trim() === "") {
            event.preventDefault(); // Ngăn chặn hành động mặc định của nút submit
            alert("Vui lòng nhập họ và tên"); // Hiển thị thông báo lỗi
            check = false
            return;
        }
        if (fullname.trim() === "" || nameRegex.test($("#fullname").val()) == false) {
            event.preventDefault(); // Ngăn chặn hành động mặc định của nút submit
            alert("Vui lòng nhập họ và tên"); // Hiển thị thông báo lỗi
            check = false
            return;
        }
    });

function checkinput() {
    // console.log(check);
    return check
}
document.getElementById("form").addEventListener('submit', function (event) {
    console.log('click')
    event.preventDefault();
    if (checkinput()) {
        if (confirm("Xác nhận rút tiền trong sổ tiết kiệm?")) {
            var form = event.target;
            var formData = {};
            for (var i = 0; i < form.elements.length - 1; i++) {
                var element = form.elements[i];
                if (element.type !== 'submit') {
                    formData[element.name] = element.value;
                }
            }
            postData('/withdraw', formData)
                .then((data) => {
                    alert(data.msg)
                    if (data.msg == "Rút tiền thành công") {
                        window.open("/withdraw/print", '_blank');
                    }
                })
        }
    }


})