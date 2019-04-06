const mongoose = require("mongoose");

const historySchema = new mongoose.Schema(
    {
        type: {
            type: String,
            required: true
        },
        imagePath: {
            type: String,
            required: false
        },
        user_id: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User"
        }
    },
    {
        timestamps: true
    }
);


const History = mongoose.model("History", historySchema);

module.exports = History;