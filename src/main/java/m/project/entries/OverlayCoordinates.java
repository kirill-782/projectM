package m.project.entries;

import javax.persistence.*;

@Entity
@Table(name = "overlayСoordinates")

public class OverlayCoordinates {

    @Column(name = "id")
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private int id;

    @Column(name = "x")
    private double x;

    @Column(name = "y")
    private double y;

    @Column(name = "orderId")
    private int order;

    @ManyToOne(targetEntity = Overlay.class, cascade = CascadeType.ALL)
    @JoinColumn(name="overlayId")
    private Overlay overlay;

    public int getId() {
        return id;
    }

    public double getX() {
        return x;
    }

    public OverlayCoordinates setX(double x) {
        this.x = x;
        return this;
    }

    public double getY() {
        return y;
    }

    public OverlayCoordinates setY(double y) {
        this.y = y;
        return this;
    }

    public Overlay getOverlay() {
        return overlay;
    }

    public OverlayCoordinates setOverlay(Overlay overlayId) {
        this.overlay = overlayId;
        return this;
    }

    public int getOrder() {
        return order;
    }

    public OverlayCoordinates setOrder(int order) {
        this.order = order;
        return this;
    }
}
