﻿using UnityEngine;
using System.Collections.Generic;

public class DecalPolygon
{
    public List<Vector3> vertices = new List<Vector3>(9);

    private static bool[] positive;
    private static int positiveCount = 0;

    public DecalPolygon(params Vector3[] vts)
    {
        vertices.AddRange(vts);
    }

    public static DecalPolygon ClipPolygon(DecalPolygon polygon, Plane plane)
    {
        positive = new bool[9];
        positiveCount = 0;

        for (int i = 0; i < polygon.vertices.Count; i++)
        {
            positive[i] = !plane.GetSide(polygon.vertices[i]);
            if (positive[i]) positiveCount++;
        }

        if (positiveCount == 0) return null;
        if (positiveCount == polygon.vertices.Count) return polygon;

        DecalPolygon tempPolygon = new DecalPolygon();

        for (int i = 0; i < polygon.vertices.Count; i++)
        {
            int next = i + 1;
            next %= polygon.vertices.Count;

            if (positive[i])
            {
                tempPolygon.vertices.Add(polygon.vertices[i]);
            }

            if (positive[i] != positive[next])
            {
                Vector3 v1 = polygon.vertices[next];
                Vector3 v2 = polygon.vertices[i];

                float dist = 0f;
                Ray ray = new Ray(v1, v2 - v1);
                plane.Raycast(ray, out dist);
                tempPolygon.vertices.Add(ray.GetPoint(dist));
            }
        }

        return tempPolygon;
    }
}