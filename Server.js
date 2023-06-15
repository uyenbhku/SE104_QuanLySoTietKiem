const express = require('express');
const { dirname } = require('path');
const app = express()
const path = require('path');
const cookieParser = require('cookie-parser');
const session = require('express-session');
registerR = require('./routes/register.r')
loginR = require('./routes/login.r')
homeR = require('./routes/home.r')
depositR = require('./routes/deposit.r')
withdrawR = require('./routes/withdraw.r')
searchR = require('./routes/search.r')
reportR = require('./routes/report.r')
// const passport = require('passport');
const passport = require('./config/passportConfig')

require('dotenv').config()
require('./config/exphbsConfig')(app);

app.use(express.static(path.join(__dirname, "public")))
// app.use("/imh",express.static(__dirname + "public/img"));
app.use(express.urlencoded({ extended: false }))
app.use(express.json())
app.use(cookieParser())
// app.use(bodyParser())
app.use(session({
    secret: 'keyboard cat',
    resave: false,
    saveUninitialized: true,
    cookie: {

        // Session expires after 24 min of inactivity.
        expires: 24 * 60000
    }

}))

app.use(passport.initialize())
app.use(passport.session())

port = process.env.PORT || 30001;

app.use('/login', loginR)

app.use((req, res, next) => {
    if (req.isAuthenticated()) {
        next()
        return
    }
    res.redirect('/login');
})
app.get('/', (req, res) => {
    res.redirect('/home')
})
app.use('/register', registerR)
app.use('/home', homeR)
app.use('/withdraw', withdrawR)
app.use('/deposit', depositR)
app.use('/search', searchR)
app.use('/report', reportR)
app.get('/logout', (req, res) => {
    if (req.isAuthenticated()) {
        req.logout(err => {
            console.log('user logout', err);
            if (err) {
                return next(err);
            }
        });
    }
    res.redirect('/login')
})

app.listen(port, () => {
    console.log('Server running at port ' + port);
});