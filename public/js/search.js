var nameRegex =
  /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềểếỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ\s\W|_]+$/;
var idRegex = /([1-9]{1})+([0-9]{8,11})\b/;

function checkinput() {
  if (
    $("#citizenID").val() != "" &&
    idRegex.test($("#citizenID").val()) == false
  ) {
    alert("CMND/CCCD không hợp lệ!!");
    return false;
  }
  return true
}

function checkinputChange() {
  if ($("#forminfo #citizenID").val().trim() == "") {
    alert("CMND/CCCD không hợp lệ!");
    return false;
  }
  if (
    $("#forminfo #citizenID").val().trim() != "" &&
    idRegex.test($("#forminfo #citizenID").val()) == false
  ) {
    alert("CMND/CCCD không hợp lệ!");
    return false;
  }
  if (
    $("#nameID").val().trim() == "" ||
    nameRegex.test($("#nameID").val()) == false
  ) {
    alert("Tên không hợp lệ!");
    return false;
  }
  if ($("#addressID").val().trim() == "") {
    alert("Địa chỉ không hợp lệ!");
    return false;
  }
  if ($("#phoneID").val().trim() == "") {
    alert("Số điện thoại không hợp lệ!");
    return false;
  }
  if ($("#phoneID").val().trim() != "" && idRegex.test($("#phoneID").val()) == false) {
    alert("Số điện thoại không hợp lệ!");
    return false;
  }

  return true;
}


var depositInfo = null
function getJSBTN() {
  // Get the modal
  var modal = document.getElementById("myModal");

  // Get the button that opens the modal
  var btns = document.getElementsByClassName("myBtn");

  // Get the <span> element that closes the modal
  var span = document.getElementsByClassName("close")[0];

  // When the user clicks the button, open the modal
  for (var i = 0; i < btns.length; i++) {
    btns[i].onclick = function (event) {
      modal.style.display = "block";
      var cells = this.closest("tr").getElementsByTagName("td");
      var info = { DepositID: cells[0].innerText }
      postData("/search/detail", info)
        .then((data) => {
          depositInfo = data.depositInfo

          document.querySelector("#myModal #customerID").value = depositInfo.CustomerID
          document.querySelector("#myModal #citizenID").value = depositInfo.CitizenID
          document.querySelector("#myModal #nameID").value = depositInfo.CustomerName
          document.querySelector("#myModal #phoneID").value = depositInfo.PhoneNumber
          document.querySelector("#myModal #addressID").value = depositInfo.CustomerAddress

          document.querySelector("#myModal #depositID").value = depositInfo.DepositID
          document.querySelector("#myModal #moneyID").value = depositInfo.Fund
          document.querySelector("#myModal #deadlineID").value = depositInfo.Term
          document.querySelector("#myModal #rateID").value = depositInfo.InterestRate
          document.querySelector("#myModal #benefitID").value = depositInfo.TotalChanges
          document.querySelector("#myModal #remainderID").value = depositInfo.CurrentBalance
          document.querySelector("#myModal #openDay").value = depositInfo.OpenedDate
          document.querySelector("#myModal #noDepositDays").value = depositInfo.NoDaysDeposited

          if (depositInfo.Withdrawer == null) {
            document.querySelector("#myModal #getID").setAttribute('readonly', true)
            document.querySelector("#myModal #getID").value = null
          }
          else {
            document.querySelector("#myModal #getID").removeAttribute('readonly')
            document.querySelector("#myModal #getID").value = depositInfo.Withdrawer
          }

          document.querySelector("#myModal #dateID").value = (depositInfo.WithdrawalDate === null) ? null : depositInfo.WithdrawalDate.split("T")[0]
        }
        )
    };
  }
  // When the user clicks on <span> (x), close the modal
  span.onclick = function () {
    modal.style.display = "none";
  };

  // When the user clicks anywhere outside of the modal, close it
  window.onclick = function (event) {
    if (event.target == modal) {
      modal.style.display = "none";
    }
  };
}
formSearch = document.getElementById('form')
// event handlers for btn search
formSearch.addEventListener('submit', function (event) {
  event.preventDefault(); // Prevent form submission
  console.log('click')
  var form = event.target;
  var formData = {};
  for (var i = 0; i < form.elements.length - 1; i++) {
    var element = form.elements[i];
    if (element.type !== 'submit') {
      formData[element.name] = element.value;
    }
  }
  if (checkinput())
    postData("/search", formData)
      .then(datas => {

        var TableBody = document.querySelector('#tbody');
        while (TableBody.firstChild) {
          TableBody.removeChild(TableBody.firstChild);
        }

        document.getElementById("hide_table").classList.remove("hide_table")
        // else
        //   document.getElementById("hide_table").classList.add("hide_table")
        for (i in datas.detailDeposit) {
          var newRow = '<tr>' +
            `<td>${datas.detailDeposit[i].DepositID}</th>` +
            `<td>${datas.detailDeposit[i].CustomerID}</th>` +
            `<td>${datas.detailDeposit[i].CustomerName}</th>` +
            `<td>${datas.detailDeposit[i].CurrentBalance}</th>` +
            `<td>${datas.detailDeposit[i].OpenedDate.replace('T', " ").replace('.000Z', "")}</th>` +
            '<td><button class="myBtn">Xem</button></td>' +
            '</tr>';
          TableBody.insertAdjacentHTML('beforeend', newRow);
        }
        getJSBTN()
      }

      )
})

//event handler for btn change and delete  deposit info
document.querySelector('#forminfo').addEventListener('submit', function (event) {
  event.preventDefault();
  console.log("click");
  if (event.submitter.id === "changeBtn") {
    //event handler for btn change 

    if (checkinputChange()) {
      if (!confirm("Bạn có muốn sửa thông tin không?")) {
        return false
      }
      var form = event.target;
      var formData = {};
      for (var i = 0; i < form.elements.length - 1; i++) {
        var element = form.elements[i];
        if (element.type !== 'submit') {
          formData[element.name] = element.value;
        }
      }
      if (depositInfo.Withdrawer != null && formData.getID.trim() != "" && depositInfo.Withdrawer != formData.getID) {
        alert("Warning: Phiếu rút chỉ được hủy người rút (hủy phiếu rút) chứ không đổi tên người rút!")
        return false
      }
      data = {
        CustomerID: formData.customerID,
        CustomerName: (depositInfo.CustomerName == formData.nameID) ? null : formData.nameID,
        CustomerAddress: (depositInfo.CustomerAddress == formData.addressID) ? null : formData.addressID,
        PhoneNumber: (depositInfo.PhoneNumber == formData.phoneID) ? null : formData.phoneID,
        CitizenID: (depositInfo.CitizenID == formData.citizenID) ? null : formData.citizenID,
        DepositID: (formData.getID.trim() == "" && depositInfo.Withdrawer != null) ? depositInfo.DepositID : false
      }
      postData('/search/detail/change', data)
        .then((datas) => {
          alert(datas.mess)
          if (datas.status == true) {
            document.getElementById("myModal").style.display = "none";
            document.getElementById('confirmBtn').click();

          }
        })

    }
  }
  else if (event.submitter.id === "deleteBtn") {

    if (!confirm("Bạn có chắc chắn xóa phiếu gửi?")) {
      return false
    }
    var form = event.target;
    postData('/search/detail/delete', { DepositID: form.elements.depositID.value })

      .then((datas) => {
        alert(datas.mess)
        if (datas.status == true) {
          document.getElementById("myModal").style.display = "none";
          document.getElementById('confirmBtn').click();
        }

      })

    //event handler for btn  delete
  }
})
