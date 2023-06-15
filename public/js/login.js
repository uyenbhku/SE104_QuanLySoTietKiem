

var userForm = document.querySelector('#form');

var username = document.getElementById("username");
var password = document.getElementById("password");

var registerBtn = document.querySelector("#registerBtn");
var loginBtn = document.querySelector("#loginBtn");

var usernameWarn = document.getElementById('username_warning');
var passwordWarn = document.getElementById('pass_warning');
function getDatabase() { return JSON.parse(localStorage.getItem('userDatabase')); }

function saveDatabase(userDatabase = []) { localStorage.setItem('userDatabase', JSON.stringify(userDatabase)); }

function checkUserInfo(userInfo) {
    var checkRegister = true;
    if (userInfo.usernameData.trim() == "") { usernameWarn.textContent = 'Username must be filled'; checkRegister = false; }
    if (userInfo.passData == "") { passwordWarn.textContent = 'Password must be filled'; checkRegister = false; }

    return checkRegister;
}

function resetWarning() {
    usernameWarn.textContent = '';
    passwordWarn.textContent = '';
}

$("#form").submit(function (e) {
    e.preventDefault();
    resetWarning();
    var userInfo = {
        usernameData: username.value,
        passData: password.value,
    };
    var checkStep1 = checkUserInfo(userInfo);
    if (checkStep1 == true) {
        var form = $(this);
        var actionUrl = form.attr('action');

        $.ajax({
            type: "POST",
            url: actionUrl,
            data: form.serialize(), // serializes the form's elements.
            success: function (data) {
                // console.log(data)
                if (data.msg !== "succeed") alert(data.msg);
                else {
                    window.location.replace("/home");
                }
            }
        });
    }
});

