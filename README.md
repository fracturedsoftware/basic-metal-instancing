# basic-metal-instancing
 
Nearly all the examples of instanced drawing for Metal that you will find on the net use an existing mesh created via MDLMesh etc. for the vertices. I wanted to be able to create the vertices programmatically and struggled a bit before asking a [question on Stack Overflow.](https://stackoverflow.com/questions/62737153/simple-example-of-instance-drawing-in-metal?noredirect=1#comment110969749_62737153)

As is often the case I managed to figure it out and came up with the three playgrounds here which are very basic examples of how to do instanced drawing in Metal. They all use indexed drawing using the drawIndexedPrimatives drawing command.
 
**UPDATE:** warrenm has another great example [here](https://github.com/metal-by-example/simple-instancing)
 
## Playground 1 - Indexed Triangle

This playground is probably the simplest example of indexed drawing that you can have. It differs from a basic ‘Hello Triangle’ example in 4 ways:

* It uses an index array to describe the triangle vertices.
* It creates a vertex descriptor and adds it to the pipeline descriptor.
* It uses the drawIndexedPrimatives drawing command.
* It uses the [[instance_id]] and [[stage_in]] attributes within the vertex shader.

By itself this example isn’t very useful because we are only drawing a triangle and therefore we aren’t sharing any vertices, which is the reason why we use indexed drawing in the first place! You can however now draw several instances of your triangle by changing the instance count to whatever you like. You won’t see them though because they will all draw directly on top of each other.

You can verify for yourself that there are multiple copies of the triangle being drawn by:

* uncomment the colorAttachments section in the initializeMetal() function, to enable alpha blending. 
* set the alpha of the vertex_out.color in the shader to something like 0.1 eg. float4( 1.0, 0.0, 0.0, 0.1 ). 
* run the playground several times incrementing the instanceCount parameter of drawIndexedPrimatives.

You will find that the triangle will be darker or lighter depending on the number of instances drawn.

## Playground 2 - Indexed Quad

The Indexed Quad example is where things get slightly more interesting. We draw a quad this time, made up of two triangles. The example here initially creates 6 vertices for 2 triangles and adds the indices for the second triangle to the indices array. The two triangles are exactly the same except that the y value of the second triangle is reversed so it draws upside down. The other two vertices of the second triangle are exactly the same as the first triangle. The vertices aren’t being shared.

However rather than sending 6 vertices for two triangles, we could send only 4, sharing 2 of the vertices with each triangle. This reduces the amount of data needing to be sent to the GPU by 1/3. Of course in this example it doesn’t make much difference because we also have to send a larger index buffer but if we wanted to draw the quad multiple times the savings add up.

Sharing the two vertices is simple:
* Change the vertexCount property to 4. You could delete the last two Vertexes from the vertexData array but it isn’t necessary for now.
* Change the indices array to [0, 1, 2, 3, 2, 1]. This basically says that triangle1 uses vertices [0, 1, 2] and triangle2 uses vertices [3, 2, 1] with vertices 1 and 2 being shared.

If you run the playground you will get the same quad as before and if you increase the instanceCount you will get multiple instances. Since the quads still draw on top of each other, I have left the alpha blending on in this example so the quad will be quite faint with only one instance but darken as the number of instances increases.

## Playground 3 - Instanced Quads

As we’ve seen in the previous two examples, after we have indexed drawing worked out instanced drawing is actually pretty straight forward. But at the moment our instances are all the same, so they draw on top of each other, which isn’t very useful. What we need is to do is create an array of structures containing data for each individual instance. We then create a buffer of this data and send it to the GPU. The vertex shader can then use this info to modify each instance.

This example just alters the position of each instance. To do this we create an array of InstanceInfo structures, one for each instance, initialized to a random position. We create a buffer of this data and send it to the GPU at index 1. Inside the shader we have the same InstanceInfo structure and we can get the individual instance data using [[instance-id]]. Since our info is just a matrix we can multiply it with the vertex_in.position to set each instances position.

