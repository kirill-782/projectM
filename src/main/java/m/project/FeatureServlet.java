package m.project;

import m.project.entries.GeometryType;
import m.project.entries.Overlay;
import m.project.entries.OverlayCoordinates;
import org.hibernate.Session;
import org.hibernate.SessionFactory;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;

import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import org.hibernate.query.Query;
import org.hibernate.transform.Transformers;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "featureServlet", value = "/feature")
public class FeatureServlet extends HttpServlet {

    static final private SessionFactory factory = new Configuration().configure().buildSessionFactory();

    public void doGet(HttpServletRequest request, HttpServletResponse response) {

        try (Session session = factory.openSession())
        {

            Query query = session.createQuery("FROM Overlay");
            List<Overlay> lol = query.list();

            JSONArray jsonArray = new JSONArray();

            for (Overlay i :
                    lol) {
                JSONObject overlayJsonObject = new JSONObject();
                overlayJsonObject.put("id", i.getId());
                overlayJsonObject.put("name", i.getName());
                overlayJsonObject.put("geometryType", i.getGeometryType().ordinal());

                JSONArray coordinates = new JSONArray();

                ArrayList<OverlayCoordinates> coordinatesSorted = new ArrayList<>(i.getCoordinatesList());
                coordinatesSorted.sort(Comparator.comparingInt(OverlayCoordinates::getOrder));

                for(OverlayCoordinates j : coordinatesSorted)
                {
                    JSONArray coordinate = new JSONArray();
                    coordinate.put(j.getX());
                    coordinate.put(j.getY());

                    coordinates.put(coordinate);
                }

                overlayJsonObject.put("coordinates",coordinates);
                jsonArray.put(overlayJsonObject);
            }

            response.getWriter().println(jsonArray.toString());

        }
        catch (Exception e)
        {
            response.setStatus(500);
        }
    }

    @Override
    public void doDelete(HttpServletRequest request, HttpServletResponse response)
    {
        try (Session session = factory.openSession())
        {
            Transaction txn = session.beginTransaction();

            Query q = session.createQuery("delete Overlay where id = :id");
            q.setParameter("id", Integer.parseInt( request.getParameter("id") ));

            if(q.executeUpdate() == 0)
                response.setStatus(404);

            txn.commit();

        }
        catch (NumberFormatException e)
        {
            response.setStatus(400);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            response.setStatus(500);
            return;
        }
    }

    @Override
    public void doPost( HttpServletRequest request, HttpServletResponse response )
    {
        try (Session session = factory.openSession())
        {
            Overlay newOverlay = new Overlay();

            newOverlay.setName(request.getParameter("name"));

            int geometryType = Integer.parseInt(request.getParameter("geometryType"));

            if( geometryType >= GeometryType.values().length || geometryType < 0)
                throw new IllegalArgumentException("geometryType not known");

            newOverlay.setGeometryType(GeometryType.values()[geometryType]);

            if(newOverlay.getName().length() < 3 || newOverlay.getName().length() > 50)
                throw new IllegalArgumentException("name length invalid");

            BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream()));

            JSONArray coordinatesJson =  new JSONArray(reader.readLine());

            Collection<OverlayCoordinates> overlayCoordinatesList = new ArrayList<>();

            for(int i = 0; i < coordinatesJson.length(); ++i)
            {
                JSONArray overlayCoordinateJson = coordinatesJson.getJSONArray(i);

                OverlayCoordinates newOverlayCoordinates = new OverlayCoordinates()
                        .setX(overlayCoordinateJson.getNumber(0).doubleValue())
                        .setY(overlayCoordinateJson.getNumber(1).doubleValue())
                        .setOrder(i)
                        .setOverlay(newOverlay);

                overlayCoordinatesList.add(newOverlayCoordinates);
            }

            newOverlay.setCoordinatesList(overlayCoordinatesList);
            Serializable result = session.save(newOverlay);
            response.getWriter().println(result);

        }
        catch (NullPointerException | IllegalArgumentException e)
        {
            e.printStackTrace();
            response.setStatus(404);
        } catch (Exception e)
        {
            response.setStatus(500);
            e.printStackTrace();
        }
    }

    @Override
    public void doPut( HttpServletRequest request, HttpServletResponse response )
    {
        try (Session session = factory.openSession())
        {

            Overlay newOverlay = new Overlay();

            newOverlay.setId(Integer.parseInt(request.getParameter("id")));

            newOverlay.setName(request.getParameter("name"));

            int geometryType = Integer.parseInt(request.getParameter("geometryType"));

            if( geometryType >= GeometryType.values().length || geometryType < 0)
                throw new IllegalArgumentException("geometryType not known");

            newOverlay.setGeometryType(GeometryType.values()[geometryType]);

            if(newOverlay.getName().length() < 3 || newOverlay.getName().length() > 50)
                throw new IllegalArgumentException("name length invalid");

            BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream()));

            JSONArray coordinatesJson =  new JSONArray(reader.readLine());

            Collection<OverlayCoordinates> overlayCoordinatesList = new ArrayList<>();

            for(int i = 0; i < coordinatesJson.length(); ++i)
            {
                JSONArray overlayCoordinateJson = coordinatesJson.getJSONArray(i);

                OverlayCoordinates newOverlayCoordinates = new OverlayCoordinates()
                        .setX(overlayCoordinateJson.getNumber(0).doubleValue())
                        .setY(overlayCoordinateJson.getNumber(1).doubleValue())
                        .setOrder(i)
                        .setOverlay(newOverlay);

                overlayCoordinatesList.add(newOverlayCoordinates);
            }

            Transaction trx = session.beginTransaction();

            Query q = session.createQuery("delete OverlayCoordinates where overlay = :id");
            q.setParameter("id", newOverlay );
            q.executeUpdate();

            newOverlay.setCoordinatesList(overlayCoordinatesList);
            session.update(newOverlay);

            trx.commit();
        }
        catch (NullPointerException | IllegalArgumentException e)
        {
            e.printStackTrace();
            response.setStatus(400);
        } catch (Exception e)
        {
            response.setStatus(500);
            e.printStackTrace();
        }
    }


    public void destroy() {
    }
}
