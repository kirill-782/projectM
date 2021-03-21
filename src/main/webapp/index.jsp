<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.5.0/css/ol.css"
          type="text/css">
    <style>
        .map {
            height: 800px;
            width: 100%;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.5.0/build/ol.js"></script>

    <title>Project M</title>

    <link rel="stylesheet" type="text/css" href="semantic/dist/semantic.min.css">
    <script
            src="https://code.jquery.com/jquery-3.1.1.min.js"
            integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="
            crossorigin="anonymous"></script>
    <script src="semantic/dist/semantic.min.js"></script>

</head>
<body>
<div id="map" class="map"></div>
<div style="margin: 10px">
    <button class="ui primary button" onclick="addInteractions( 'Point' );">
        Добавить точку
    </button>
    <button class="ui primary button" onclick="addInteractions( 'LineString' );">
        Нарисовать ломаную
    </button>
    <button class="ui primary button" onclick="addInteractions( 'Polygon' );">
        Нарисовать многоугольник
    </button>
</div>

<div style="margin: 10px" class="ui grid" id="feature-list">

</div>


<script type="text/javascript">

    window.editTimeouts = [];

    initMap();

    function initMap() {
        window.source = new ol.source.Vector({wrapX: false});

        let vector = new ol.layer.Vector({
            source: source
        });

        vector.setStyle(styleFunction);

        let googleMap = new ol.layer.Tile({
            title: "Google Road Names",
            source: new ol.source.TileImage({url: 'http://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}'})
        });

        window.map = new ol.Map({
            target: 'map',
            layers: [googleMap, vector],
            view: new ol.View({
                center: ol.proj.fromLonLat([37.41, 8.82]),
                zoom: 4
            })
        });

        var modify = new ol.interaction.Modify({source: source});
        map.addInteraction(modify);

        source.addEventListener("addfeature", addFeatureCallback);
        source.addEventListener("changefeature", changeFeatureCallback);

        try {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "/Project_M_war/feature");

            xhr.onreadystatechange = () => {
                if (xhr.readyState !== 4)
                    return;

                if (xhr.status !== 200)
                    return;

                let response = JSON.parse(xhr.responseText);

                response.forEach((i) => {

                    let feature;

                    if (i.geometryType === 0) // is point
                        feature = new ol.Feature({geometry: new ol.geom.Point(i.coordinates[0])});
                    else if (i.geometryType === 1)
                        feature = new ol.Feature({geometry: new ol.geom.LineString(i.coordinates)});
                    else if (i.geometryType === 2)
                        feature = new ol.Feature({geometry: new ol.geom.Polygon([i.coordinates])});

                    feature.setId(i.id);
                    feature.setProperties({name: i.name});

                    source.addFeature(feature);
                });

            }
            xhr.send();

        } finally {

        }

    }

    function addInteractions(type) {
        window.draw = new ol.interaction.Draw({
            source: window.source,
            type: type,
        });
        map.addInteraction(window.draw);

        window.snap = new ol.interaction.Snap({source: source});
        map.addInteraction(snap);
    }

    function addFeatureCallback(e) {
        if (e.feature.getId() === undefined) {
            map.removeInteraction(draw);
            map.removeInteraction(snap);

            let name = prompt("Введите имя для новой точки");

            if (name == null || name.length == 0)
                source.removeFeature(e.feature)
            else {

                let geometryType;
                let body;

                if (e.feature.getGeometry().getType() === "Point") {
                    body = [e.feature.getGeometry().getCoordinates()]
                    geometryType = 0;
                } else if (e.feature.getGeometry().getType() === "LineString") {
                    body = e.feature.getGeometry().getCoordinates();
                    geometryType = 1;
                } else if (e.feature.getGeometry().getType() === "Polygon") {
                    body = e.feature.getGeometry().getCoordinates()[0];
                    geometryType = 2;
                }

                let xhr = new XMLHttpRequest();
                xhr.open("POST", "/Project_M_war/feature?name=" + encodeURIComponent(name) + "&geometryType=" + geometryType);
                xhr.onreadystatechange = () => {

                    if (xhr.readyState !== 4)
                        return;

                    if (xhr.status !== 200) {
                        alert("Ошибка сохранения точки");
                    }
                    else
                    {
                        e.feature.setId(parseInt(xhr.responseText));
                        e.feature.setProperties({name: name});
                        addFeatureInList(e.feature);
                    }
                };
                xhr.send(JSON.stringify(body));
            }

        }
        else
            addFeatureInList(e.feature);
    }

    function changeFeatureCallback(e) {
        clearTimeout(window.editTimeouts[e.feature.getId()]);

        // Для избежания флуда отправляем изменения на конечную точку спустя 0,5 секунды
        // после последнего изменения координат

        window.editTimeouts[e.feature.getId()] = setTimeout(() => {
            let geometryType;
            let body;

            if (e.feature.getGeometry().getType() === "Point") {
                body = [e.feature.getGeometry().getCoordinates()]
                geometryType = 0;
            } else if (e.feature.getGeometry().getType() === "LineString") {
                body = e.feature.getGeometry().getCoordinates();
                geometryType = 1;
            } else if (e.feature.getGeometry().getType() === "Polygon") {
                body = e.feature.getGeometry().getCoordinates()[0];
                geometryType = 2;
            }

            let xhr = new XMLHttpRequest();
            xhr.open("PUT", "/Project_M_war/feature?id=" + e.feature.getId() + "&name=" + encodeURIComponent(e.feature.getProperties().name) + "&geometryType=" + geometryType);

            xhr.onreadystatechange = () => {
                if (xhr.readyState !== 4)
                    return;

                if (xhr.status === 200)
                    console.log("Точка обновлена");
                else
                    alert("PUT: Сервер вернул неожиданный ответ - " + xhr.status);
            }

            xhr.send(JSON.stringify(body));
        }, 500);
    }

    function save() {
        localStorage.setItem("data", JSON.stringify(window.storage));
    }

    function deleteFeature(feature) {
        let xhr = new XMLHttpRequest();
        xhr.open("DELETE", "/Project_M_war/feature?id=" + feature.getId());
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== 4)
                return;

            if (xhr.status === 200)
            {
                source.removeFeature(feature);
                document.getElementById("feature-list").removeChild( feature.getProperties( ).listElement);
            }


            else
                alert("DELETE: Сервер вернул неожиданный ответ - " + xhr.status);
        }
        xhr.send();
    }

    function styleFunction(feature, resolution) {
        return new ol.style.Style({
            fill: new ol.style.Fill({
                color: 'rgba(255, 255, 255, 0.2)',
            }),
            stroke: new ol.style.Stroke({
                color: '#ffcc33',
                width: 2,
            }),
            image: new ol.style.Circle({
                radius: 7,
                fill: new ol.style.Fill({
                    color: '#ffcc33',
                }),
            }),
            text: new ol.style.Text({
                text: feature.getProperties().name,
                font: "bold 12px/1.2 'Courier New' "
            })
        })
    }

    function addFeatureInList(feature) {
        let element = document.createElement("div");

        element.classList.add("two", "column", "row");
        element.innerHTML = `
        <div class="left floated column"><p>Luna</p></div>
        <div class="right floated right column">
            <p>
                <button class="ui icon button right floated"><i class="close icon"></i>
                </button>
            </p>
        </div>
        `;


        element.querySelector("button").addEventListener("click", ()=>{
            deleteFeature(feature);
        })
        element.querySelector("p").innerText = feature.getProperties().name;
        feature.setProperties({listElement : element});

        document.getElementById("feature-list").appendChild(element);

    }

</script>
</body>


</html>

