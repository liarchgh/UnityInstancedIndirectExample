using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// This demo shows the use of the procedural instancing features to render objects
/// without need of any position buffer. The values are calculated direclty inside the 
/// shader. 
/// The color buffer is used for debug only.
/// </summary>
public class ShowRowsInGPUIns : MonoBehaviour {
    public int instanceCount = 0;
    public Mesh instanceMesh;
    public Material instanceMaterial;

    public ShadowCastingMode castShadows = ShadowCastingMode.Off;
    public bool receiveShadows = false;

    private ComputeBuffer argsBuffer;
    private ComputeBuffer colorBuffer;
    private ComputeBuffer positionBuffer;
    private ComputeBuffer rotationBuffer;

    private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };

    void OnEnable() {
        argsBuffer = new ComputeBuffer (5, sizeof (uint), ComputeBufferType.IndirectArguments);
        CreateBuffers ();
    }

    void Update () {
        Graphics.DrawMeshInstancedIndirect (instanceMesh, 0, instanceMaterial, instanceMesh.bounds, argsBuffer, 0, null, castShadows, receiveShadows);
    }

    void CreateBuffers () {
        if (instanceCount < 1) instanceCount = 1;

        //instanceCount = Mathf.ClosestPowerOfTwo(instanceCount);
        instanceMesh.bounds = new Bounds (Vector3.zero, Vector3.one * 10000f); //avoid culling

        /// Colors - for debug only
        if (positionBuffer != null) positionBuffer.Release ();
        positionBuffer = new ComputeBuffer (instanceCount, 16);
        if (colorBuffer != null) colorBuffer.Release ();
        colorBuffer = new ComputeBuffer (instanceCount, 16);
        if (rotationBuffer != null) rotationBuffer.Release ();
        rotationBuffer = new ComputeBuffer (instanceCount, 16);


        // Vector4[][] colors = new Vector4[instanceCount][];
        Vector4[] buffer = new Vector4[instanceCount];
        for (int i = 0; i < instanceCount; i++) {
            buffer[i] = new Vector4 (Random.Range (0.0f, 10000.0f) / 100.0f, Random.Range (0.0f, 10000.0f) / 100.0f, Random.Range (0.0f, 10000.0f) / 100.0f, 10);
        }

        positionBuffer.SetData (buffer);
        instanceMaterial.SetBuffer ("positionBuffer", positionBuffer);

        buffer = new Vector4[instanceCount];
        for (int i = 0; i < instanceCount; i++) {
            buffer[i] = new Vector4 (Random.Range (0.0f, 10000.0f) / 100.0f, Random.Range (0.0f, 10000.0f) / 100.0f, Random.Range (0.0f, 10000.0f) / 100.0f, 10);
        }

        rotationBuffer.SetData (buffer);
        instanceMaterial.SetBuffer ("rotationBuffer", rotationBuffer);

        buffer = new Vector4[instanceCount];
        for (int i = 0; i < instanceCount; i++) {
            buffer[i] = Random.ColorHSV ();
            // buffer[i] = new Vector4 (1, 1, 0, 1);
        }

        colorBuffer.SetData (buffer);
        instanceMaterial.SetBuffer ("colorBuffer", colorBuffer);

        // instanceMaterial.SetBuffer ("rotationBuffer", shaderBuffer);
        // indirect args
        uint numIndices = (instanceMesh != null) ? (uint) instanceMesh.GetIndexCount (0) : 0;
        args[0] = numIndices;
        args[1] = (uint) instanceCount;
        argsBuffer.SetData (args);
    }

    void OnDisable () {
        if (colorBuffer != null) colorBuffer.Release ();
        colorBuffer = null;
        if (positionBuffer != null) positionBuffer.Release ();
        positionBuffer = null;
        if (rotationBuffer != null) rotationBuffer.Release ();
        rotationBuffer = null;

        if (argsBuffer != null) argsBuffer.Release ();
        argsBuffer = null;
    }

    void OnGUI () {
        GUI.Label (new Rect (265, 12, 200, 30), "Instance Count: " + instanceCount.ToString ("N0"));
    }
}
