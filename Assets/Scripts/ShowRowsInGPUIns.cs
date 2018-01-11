using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// This demo shows the use of the procedural instancing features to render objects
/// without need of any position buffer. The values are calculated direclty inside the 
/// shader. 
/// The color buffer is used for debug only.
/// </summary>
public class ShowRowsInGPUIns : MonoBehaviour {
    public int gridDim = 1000;
    public int instanceCount = 0;
    public Mesh instanceMesh;
    public Material instanceMaterial;

    public ShadowCastingMode castShadows = ShadowCastingMode.Off;
    public bool receiveShadows = false;

    private ComputeBuffer argsBuffer;
    private ComputeBuffer colorBuffer;

    private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };

    void Start () {
        instanceCount = gridDim * gridDim;
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
        if (colorBuffer != null) colorBuffer.Release ();

        colorBuffer = new ComputeBuffer (instanceCount * 3, 16);

        // Vector4[][] colors = new Vector4[instanceCount][];
        Vector4[] colors = new Vector4[instanceCount * 3];
        for (int i = 0; i < instanceCount; i++) {
            // colors[i] = new Vector4[2];
            colors[i * 2] = new Vector4(Random.Range (0, 10000) / 100.0f, Random.Range (0, 10000) / 100.0f, Random.Range (0, 10000) / 100.0f, 10);

            colors[i * 2 + 1] = Random.ColorHSV ();
            colors[i * 2 + 2] = Random.ColorHSV ();
            // colors[i][0] = Random.ColorHSV ();
            // colors[i][1] = new Vector4 (i * i, i * i, i * i, 1);
        }

        colorBuffer.SetData (colors);

        instanceMaterial.SetBuffer ("colorBuffer", colorBuffer);

        // indirect args
        uint numIndices = (instanceMesh != null) ? (uint) instanceMesh.GetIndexCount (0) : 0;
        args[0] = numIndices;
        args[1] = (uint) instanceCount;
        argsBuffer.SetData (args);

        Shader.SetGlobalFloat ("_Dim", gridDim);
    }

    void OnDisable () {
        if (colorBuffer != null) colorBuffer.Release ();
        colorBuffer = null;

        if (argsBuffer != null) argsBuffer.Release ();
        argsBuffer = null;
    }

    void OnGUI () {
        GUI.Label (new Rect (265, 12, 200, 30), "Instance Count: " + instanceCount.ToString ("N0"));
    }
}

// using UnityEngine;
// using UnityEngine.Rendering;

// /// <summary>
// /// This demo shows the use of the procedural instancing features to render objects
// /// without need of any position buffer. The values are calculated direclty inside the 
// /// shader. 
// /// The color buffer is used for debug only.
// /// </summary>
// public class ShowRows : MonoBehaviour {
//     // //基准数量
//     // public int gridDim = 1000;
//     //物体个数
//     public int instanceCount = 0;
//     public Mesh instanceMesh;
//     public Material instanceMaterial;

//     public ShadowCastingMode castShadows = ShadowCastingMode.Off;
//     public bool receiveShadows = false;

//     private ComputeBuffer argsBuffer;
//     private ComputeBuffer shderBuffer;

//     private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };

//     void Start () {
//         // instanceCount = gridDim * gridDim;
//         argsBuffer = new ComputeBuffer (5, sizeof (uint), ComputeBufferType.IndirectArguments);
//         CreateBuffers ();
//     }

//     void Update () {
//         Graphics.DrawMeshInstancedIndirect (instanceMesh, 0, instanceMaterial, instanceMesh.bounds, argsBuffer, 0, null, castShadows, receiveShadows);
//     }

//     void CreateBuffers () {
//         if (instanceCount < 1) instanceCount = 1;

//         //instanceCount = Mathf.ClosestPowerOfTwo(instanceCount);
//         instanceMesh.bounds = new Bounds (Vector3.zero, Vector3.one * 10000f); //avoid culling

//         /// Colors - for debug only
//         if (shderBuffer != null) shderBuffer.Release ();

//         shderBuffer = new ComputeBuffer (instanceCount, 48);

//         Vector4[][] colAPos = new Vector4[instanceCount][];
//         for (int i = 0; i < instanceCount; i++) {
//             colAPos[i] = new Vector4[3];
//         }
//         for (int i = 0; i < instanceCount; i++) {
//             colAPos[i][0] = Random.ColorHSV ();
//             colAPos[i][1] = new Vector4 (i * i, i * i, i * i, 1);
//             colAPos[i][2] = new Vector4 (1, 1, 1, 1);
//         }

//         shderBuffer.SetData (colAPos[0]);

//         // instanceMaterial.SetFloat ("_PosX", 100);
//         // instanceMaterial.SetFloat ("_PosY", 100);
//         // instanceMaterial.SetFloat ("_PosZ", 100);
//         instanceMaterial.SetBuffer ("shderBuffer", shderBuffer);

//         // indirect args
//         uint numIndices = (instanceMesh != null) ? (uint) instanceMesh.GetIndexCount (0) : 0;
//         args[0] = numIndices;
//         args[1] = (uint) instanceCount;
//         argsBuffer.SetData (args);

//         // Shader.SetGlobalFloat ("_Dim", gridDim);
//         // Shader.SetGlobalFloat ("_Dim", instanceCount);
//     }

//     void OnDisable () {
//         if (shderBuffer != null) shderBuffer.Release ();
//         shderBuffer = null;

//         if (argsBuffer != null) argsBuffer.Release ();
//         argsBuffer = null;
//     }

//     void OnGUI () {
//         GUI.Label (new Rect (265, 12, 200, 30), "Instance Count: " + instanceCount.ToString ("N0"));
//     }
// }