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
    alert("CMND/CCCD không hợp lệ!!");
    return false;
  }
  return true;
}
