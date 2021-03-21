package m.project.entries;

import org.hibernate.annotations.Generated;

import javax.persistence.*;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "overlay")
public class Overlay {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private int id;

    @Column(name = "name")
    private String name;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "geometryType")
    private GeometryType geometryType;

    @OneToMany(orphanRemoval = true, mappedBy = "overlay", cascade = CascadeType.ALL)
    private Collection<OverlayCoordinates> coordinatesList;

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Overlay setName(String name) {
        this.name = name;
        return this;
    }

    public GeometryType getGeometryType() {
        return geometryType;
    }

    public Overlay setGeometryType(GeometryType geometryType) {
        this.geometryType = geometryType;
        return this;
    }

    public Collection<OverlayCoordinates> getCoordinatesList() {
        return coordinatesList;
    }

    public Overlay setCoordinatesList(Collection<OverlayCoordinates> coordinatesList) {
        this.coordinatesList = coordinatesList;
        return this;
    }

    public Overlay setId(int id) {
        this.id = id;
        return this;
    }
}
