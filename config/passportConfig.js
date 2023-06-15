const passport = require('passport');
const localStrategy = require('passport-local').Strategy;
const userM = require('../models/user.m');
const bcrypt = require('bcrypt');

// kiểm tra xem mật khẩu có đúng không
passport.serializeUser((user, done) => {
    done(null, user)
})
passport.deserializeUser(async (Username, done) => {
    try {
        const user = await userM.getAccountByUsername(Username);
        done(null, user[0].Username);
    }
    catch (err) {
        done(err, null);
    }
})
passport.use(new localStrategy(
    async (Username, Password, done) => {
        try {

            const user = await userM.getAccountByUsername(Username)
            if (!user) return done(null, false)
            // let cmp = await bcrypt.compare(password, user[0].ENCRYPT_PASSWORD)
            const cmp = Password == user[0].AccountPassword
            if (!cmp) return done(null, false)
            return done(null, user[0].Username);
        }
        catch (err) {
            return done(err);
        }
    }
))
module.exports = passport