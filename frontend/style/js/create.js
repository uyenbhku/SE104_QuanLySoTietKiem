var nameRegex =
  /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềểếỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ\s\W|_]+$/;
var idRegex = /([1-9]{1})+([0-9]{8,11})\b/;

function checkinput() {
  var type = $("input[name = 'type']:checked").val();
  if ($("#citizenID").val() == "") {
    alert("CMND/CCCD không hợp lệ!");
    return false;
  }
  if (
    $("#citizenID").val() != "" &&
    idRegex.test($("#citizenID").val()) == false
  ) {
    alert("CMND/CCCD không hợp lệ!");
    return false;
  }
  if (
    $("#fullname").val() == "" ||
    nameRegex.test($("#fullname").val()) == false
  ) {
    alert("Tên không hợp lệ!");
    return false;
  }
  if ($("#address").val() == "") {
    alert("Địa chỉ không hợp lệ!");
    return false;
  }
  if ($("#phone").val() == "") {
    alert("Số điện thoại không hợp lệ!");
    return false;
  }
  if ($("#phone").val() != "" && idRegex.test($("#phone").val()) == false) {
    alert("Số điện thoại không hợp lệ!");
    return false;
  }
  if ($("#type").val() == "") {
    alert("Loại tiết kiệm không hợp lệ!");
    return false;
  }
  if ($("#deposit").val() == "") {
    alert("Số tiền không hợp lệ!");
    return false;
  }
  return true;
}
var confirmMSG = "Xác nhận tạo phiếu gửi tiền mới?";
var succeedMSG = "Tạo phiếu gửi tiền mới thành công!";
var redirectURL = "#";
