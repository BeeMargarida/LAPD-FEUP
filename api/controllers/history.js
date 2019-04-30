const db = require("../models");

exports.createHistory = async function (req, res, next) {
    try {

        //body must contain: type (String), imagePath (string), user_id 
        let history = await db.History.create({
            type: data.type,
            imagePath: data.imagePath,
            user: data.user.id
        });

        return;

    } catch (err) {
        return next({
            status: 400,
            message: "An error occurred while creating an history entry."
        });
    }
}

exports.listHistory = async function (req, res, next) {
    let history = await db.History.find()
            .sort({ createdAt: "desc" })
            .populate("user", { name: true });

    return res.status(200).json(history);
}