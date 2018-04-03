function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

(function ($) {
    $.fn.count_2_amount = async function (total_money_spent) {
        var i = 0;
        sleep_time = 1

        // Repeat until i is equal to total money spent
        while (i < parseInt(total_money_spent)) {
            $("#test1").text(i + " kr");

            // Time
            if (i > (parseInt(total_money_spent) * 0.9999)) {
                i += 60;
            } else {
                i += 137;
            };

            await sleep(sleep_time);
        };

        if (i > parseInt(total_money_spent)) {
            $("#test1").text(parseInt(total_money_spent) + " kr");
        };

        // return this;
    };
})(jQuery);

function my_drawing(var1, var2) {
    new Chartkick.LineChart("chart-1", {
        var1: var2,
    })
};