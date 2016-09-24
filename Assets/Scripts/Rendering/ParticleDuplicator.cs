using UnityEngine;
using SpriteLayout;

/// <summary>
/// Script to attach to gameobjects with UnityEngine.UI.Image components, used to dissolve them into particles.
/// </summary>
public class ParticleDuplicator : MonoBehaviour
{
    private ParticleSystem ps;
    private ParticleSystem.Particle[] particles;

    private Sprite source;

    public void Activate()
    {
        ps = FindObjectOfType<ParticleSystem>();
        source = GetComponent<SpriteLayoutImage>().Sprite;

        //Emit particles from particle system and retrieve into particles array
        particles = new ParticleSystem.Particle[source.texture.width * source.texture.height];
        ps.Emit(particles.Length);
        ps.GetParticles(particles);

        //Get sprite viewport coordinates and pixel width/height on display
        SpriteLayoutBase rt = GetComponent<SpriteLayoutBase>();
        Vector2 bottomLeft = new Vector2((rt.Position.x - rt.Width / 2) / (float)Screen.width, (rt.Position.y) / (float)Screen.height);
        Vector2 topRight = new Vector2((rt.Position.x + rt.Width / 2) / (float)Screen.width, (rt.Position.y + rt.Height) / (float)Screen.height);
        Vector2 vpbl = Camera.main.ViewportToWorldPoint(bottomLeft);
        Vector2 vptr = Camera.main.ViewportToWorldPoint(topRight);
        float pxWidth = (vptr.x - vpbl.x) / rt.Width;
        float pxHeight = (vptr.y - vpbl.y) / rt.Height;

        //Modify particle placement to reform the original sprite, and put back into particle system
        int particleCount = 0;
        for (int y = 0; y < source.texture.height; y++)
        {
            float yFrac = (source.texture.height - y) / (float)source.texture.height;
            for (int x = 0; x < source.texture.width; x++)
            {
                Color c = source.texture.GetPixel(x, y);
                if (c.a == 0.0f || (c.r + c.b + c.g) == 0.0f)
                    continue;
                particles[particleCount].position = new Vector3(vpbl.x + x * pxWidth, vpbl.y + y * pxHeight, -5.0f);
                particles[particleCount].startColor = c;
                particles[particleCount].startSize = pxWidth; // we have to assume a square aspect ratio for pixels here
                particles[particleCount].lifetime = yFrac * 1.5f + UnityEngine.Random.value * 0.3f;
                particles[particleCount].startLifetime = particles[particleCount].lifetime;
                particleCount++;
            }
        }
        ps.SetParticles(particles, particleCount);
        GetComponent<SpriteLayoutImage>().RendererEnabled = false;
    }
}