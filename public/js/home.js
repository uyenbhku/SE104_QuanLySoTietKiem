$(".savingbook").click(function (e) {
    $(this).children('form').submit();
})
function checkinput() {
    if (isNaN($('#money').val()) || $('#money').val().trim() === "") {
        alert("Vui lòng nhập số tiền không nhập chữ")
        return false
    }
    if (parseInt($('#money').val()) < 0) {
        window.location.replace("/home")
        alert("Không nhập số tiền âm!")
        return false
    }
    return true
}
function checkaddinput() {
    if (isNaN($('#Term').val()) || $('#Term').val().trim() === "") {
        alert("Vui lòng nhập kì hạn là số kỳ không nhập chữ")
        return false
    } if (isNaN($('#InterestRate').val()) || $('#InterestRate').val().trim() === "") {
        alert("Vui lòng nhập lãi suất là số kỳ không nhập chữ")
        return false
    } if (isNaN($('#MinimumTimeToWithdrawal').val()) || $('#MinimumTimeToWithdrawal').val().trim() === "") {
        alert("Vui lòng nhập thời gian tối thiểu là số kỳ không nhập chữ")
        return false
    }
    if (parseInt($('#Term').val()) < 0) {
        alert("Không nhập số kì hạn âm!")
        return false
    }
    if (parseInt($('#InterestRate').val()) < 0) {
        alert("Không nhập số lãi suất âm!")
        return false
    }
    if (parseInt($('#MinimumTimeToWithdrawal').val()) < 0) {
        alert("Không nhập số ngày tối thiểu âm!")
        return false
    }
    return true
}
if (document.querySelector('#form') != null) {
    document.querySelector('#form').addEventListener('submit', function (event) {
        event.preventDefault();
        console.log("click");
        if (checkinput() && confirm("Bạn có muôn thay đổi số tiền gửi tối thiểu?")) {
            var form = event.target;
            element = form.elements[0];
            var formData = {}
            formData[element.name] = element.value;
            postData("/home", formData)
                .then(function (data) {
                    alert(data.msg)

                })

        }
    });
}
btns = document.getElementsByClassName("myBtn")
for (var i = 0; i < btns.length; i++) {

    btns[i].onclick = function (event) {

        var cells = this.closest("tr").getElementsByTagName("td");
        data = {
            text: this.textContent.trim(),
            InterestTypeID: cells[0].innerText
        }
        if (confirm(`Bạn có muôn ${data.text} loại tiết kiệm ${cells[1].innerText} `))
            postData("/home/lockorunlock", data)
                .then(function (data) {
                    alert(data.msg)
                    window.location.replace("/home")
                })
    }
}
// var tginput
// var okbtns
upbtns = document.getElementsByClassName("updateBtn")
for (var i = 0; i < btns.length; i++) {
    upbtns[i].onclick = function (event) {
        if (!document.getElementById("okBtn")) {
            this.innerHTML = "OK"
            cellsu = this.closest("tr").getElementsByTagName("td");
            oldmin = cellsu[4].innerText
            cellsu[4].contentEditable = true
            cellsu[4].focus()
            cellsu[4].onblur = function () {
                okbtns.onclick()
            }
            this.id = 'okBtn'
            this.classList.remove('updateBtn')
            var okbtns = document.getElementById("okBtn")
            okbtns.onclick = function (event) {
                cells = this.closest("tr").getElementsByTagName("td");
                if (parseInt(cells[4].innerText) < 0) {
                    alert("Vui lòng nhập ngày tối thiểu không âm")
                    window.location.replace("/home")
                    return
                }
                else if (!isNaN(cells[4].innerText) && cells[4].innerText.trim() != "") {
                    data = {
                        MinimumTimeToWithdrawal: cells[4].innerText,
                        InterestTypeID: cells[0].innerText

                    }
                    postData("/home/update", data)
                        .then((data) => {
                            alert(data.msg)
                        })

                    window.location.replace('/home')
                }
                else
                    alert("Vui lòng nhập số")
            }
        }
    }
}

add = document.getElementsByClassName("addBtn")
if (add[0])
    add[0].onclick = function (e) {
        if (checkaddinput() && confirm("Bạn muốn thêm loại tiết kiệm không?")) {
            var cells = this.closest("tr").getElementsByTagName("input");
            data = {
                InterestRate: cells[1].value,
                Term: cells[0].value,
                MinimumTimeToWithdrawal: cells[2].value
            }
            postData("/home/add", data)
                .then(function (data) {
                    alert(data.msg)
                    window.location.replace("/home")
                })
        }
    }
function formatCurrency(value) {
    return value.toLocaleString('vi-VN', { style: 'currency', currency: 'VND' });
}
document.getElementById('sumDeposit').textContent = formatCurrency(parseInt(document.getElementById('sumDeposit').textContent))
document.getElementById('MonthDeposit').textContent = formatCurrency(parseInt(document.getElementById('MonthDeposit').textContent))
document.getElementById('Monthwithdraw').textContent = formatCurrency(parseInt(document.getElementById('Monthwithdraw').textContent))
