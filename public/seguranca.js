$(document).ready(function() {
    key('0', function() {
        console.log("toogle")
        $(".passwd").toggle();
    });
});

function renderizar_admin() {
    console.log("renderizar_admin")
    var id = "snk"
    $.ajax({
        url: "/renderizar_admin/",
        type: "GET",
        data: {
            "id": id,
        }
    });
}
