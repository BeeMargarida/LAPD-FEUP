const db = require("../models");
const ITEMS_PER_PAGE = 10;

exports.createHistory = async function (data, res, next) {
    try {

        //body must contain: type (String), imagePath (string), user_id 
        let history = await db.History.create({
            type: data.type,
            imagePath: data.imagePath,
            user: data.user.id
        });

        return history;

    } catch (err) {
	console.log(err);
        return next({
            status: 400,
            message: "An error occurred while creating an history entry."
        });
    }
}

exports.listHistory = async function (req, res, next) {
    let history;

    if(req.query.page != undefined){
        const pageNo = parseInt(req.query.page);
        const itemsPerPage = parseInt(req.query.per_page) || ITEMS_PER_PAGE;
        history = await db.History.find()
                    .skip(itemsPerPage*(pageNo-1))
                    .limit(itemsPerPage)
                    .sort({ createdAt: "desc" })
                    .populate("user", { name: true });
    }
    else{
        history = await db.History.find()
                .sort({ createdAt: "desc" })
                .populate("user", { name: true });
    }
    return res.status(200).json(history);
}
