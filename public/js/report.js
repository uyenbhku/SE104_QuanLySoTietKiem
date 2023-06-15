
function checkinput() {
    if ($("#dateID").val().trim() === "") {
        alert("Nhập ngày cần báo cáo!")
        return false;
    }
    return true
}
document.getElementById('form').addEventListener('submit', function (event) {
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
    if (checkinput()) {
        postData('/report', formData)
            .then((data) => {
                if (data.detailReport === false) {
                    alert("Nhập ngày nhỏ hơn hoặc bằng ngày hiện tại")
                    return
                }
                total = data.detailReport[0][0]
                totalInterestTypes = data.detailReport[1]
                document.getElementById('get').value = total.TotalRevenue
                document.getElementById('pay').value = total.TotalCost
                document.getElementById('benefit').value = total.TotalProfit

                var TableBody = document.querySelector('#tbody');
                while (TableBody.firstChild) {
                    TableBody.removeChild(TableBody.firstChild);
                }
                if (totalInterestTypes.length > 0)
                    document.getElementById("hide_table").classList.remove("hide_table")
                // else
                //   document.getElementById("hide_table").classList.add("hide_table")
                for (i in totalInterestTypes) {
                    var newRow = '<tr>' +
                        `<td>${i}</th>` +
                        `<td>${totalInterestTypes[i].InterestTypeID}</th>` +
                        `<td>${totalInterestTypes[i].Revenue}</th>` +
                        `<td>${totalInterestTypes[i].Cost}</th>` +
                        `<td>${totalInterestTypes[i].Profit}</th>` +
                        '</tr>';
                    TableBody.insertAdjacentHTML('beforeend', newRow);
                }
            })
    }


})