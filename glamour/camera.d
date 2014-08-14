/**
 * Defines the Camera class, which manages a view and projection matrix.
 * This comes form the dash engine
 */
module glamour.camera;

import gl3n.linalg;
import std.conv;

//mixin( registerComponents!q{dash.components.camera} );

/**
 * Camera manages a view and projection matrix.
 */
struct Camera {
private:
	int width;
	int height;

	vec2 _projectionConstants; // For rebuilding linear Z in shaders
	mat4 _prevLocalMatrix;
	mat4 _viewMatrix;
	mat4 _inverseViewMatrix;
	mat4 _perspectiveMatrix;
	mat4 _inversePerspectiveMatrix;
	mat4 _orthogonalMatrix;
	mat4 _inverseOrthogonalMatrix;

public:
	float fov;
	float near;
	float far;

	// x = yaw
	// y = pitch
	// z = roll
	vec3 angle;
	vec3 position;

	vec2 projectionConstants() {
		updatePerspective();
		updateOrthogonal();
		//updateProjectionDirty();

		return _projectionConstants;
	}

	mat4 perspectiveMatrix() {
		updatePerspective();
		updateOrthogonal();
		//updateProjectionDirty();

		return _perspectiveMatrix;
	}

	mat4 inversePerspectiveMatrix() {
		updatePerspective();
		updateOrthogonal();
		//updateProjectionDirty();

		return _inversePerspectiveMatrix;
	}

	mat4 orthogonalMatrix() {
		updatePerspective();
		updateOrthogonal();
		//updateProjectionDirty();

		return _orthogonalMatrix;
	}

	mat4 inverseOrthogonalMatrix() {
		updatePerspective();
		updateOrthogonal();
		//updateProjectionDirty();

		return _inverseOrthogonalMatrix;
	}

	void updateViewMatrix() {
		//Assuming pitch & yaw are in radians
		float cosPitch = cos( angle.y );
		float sinPitch = sin( angle.y );
		float cosYaw = cos( angle.x );
		float sinYaw = sin( angle.x );

		vec3 xaxis = vec3( cosYaw, 0.0f, -sinYaw );
		vec3 yaxis = vec3( sinYaw * sinPitch, cosPitch, cosYaw * sinPitch );
		vec3 zaxis = vec3( sinYaw * cosPitch, -sinPitch, cosPitch * cosYaw );

		_viewMatrix.clear( 0.0f );
		_viewMatrix[ 0 ] = xaxis.vector ~ -( xaxis * position );
		_viewMatrix[ 1 ] = yaxis.vector ~ -( yaxis * position );
		_viewMatrix[ 2 ] = zaxis.vector ~ -( zaxis * position );
		_viewMatrix[ 3 ] = [ 0, 0, 0, 1 ];

		_inverseViewMatrix = _viewMatrix.inverse();
	}

	/**
	 * Creates a view matrix looking at a position.
	 *
	 * Params:
	 *  targetPos = The position for the camera to look at.
	 *  cameraPos = The camera's position.
	 *  worldUp = The up direction in the world.
	 *
	 * Returns:
	 * A right handed view matrix for the given params.
	 */
	static mat4 lookAt( vec3 targetPos, vec3 cameraPos, 
			vec3 worldUp = vec3(0,1,0) ) 
	{
		vec3 zaxis = ( cameraPos - targetPos );
		zaxis.normalize;
		vec3 xaxis = cross( worldUp, zaxis );
		xaxis.normalize;
		vec3 yaxis = cross( zaxis, xaxis );

		mat4 result = mat4.identity;

		result[0][0] = xaxis.x;
		result[1][0] = xaxis.y;
		result[2][0] = xaxis.z;
		result[3][0] = -dot( xaxis, cameraPos );
		result[0][1] = yaxis.x;
		result[1][1] = yaxis.y;
		result[2][1] = yaxis.z;
		result[3][1] = -dot( yaxis, cameraPos );
		result[0][2] = zaxis.x;
		result[1][2] = zaxis.y;
		result[2][2] = zaxis.z;
		result[3][2] = -dot( zaxis, cameraPos );

		return result.transposed;
	}

private:

	/*
	 * Updates the projection constants, perspective matrix, and inverse perspective matrix
	 */
	void updatePerspective() {
		_projectionConstants = vec2( ( -far * near ) / ( far - near ), far / ( far - near ) );
		_perspectiveMatrix = mat4.perspective( cast(float)width, cast(float)height, 
			fov, near, far );
		_inversePerspectiveMatrix = _perspectiveMatrix.inverse();
	}

	/*
	 * Updates the orthogonal matrix, and inverse orthogonal matrix
	 */
	void updateOrthogonal() {
		_orthogonalMatrix = mat4.identity;

		_orthogonalMatrix[0][0] = 2.0f / width;
		_orthogonalMatrix[1][1] = 2.0f / height;
		_orthogonalMatrix[2][2] = -2.0f / (far - near);
		_orthogonalMatrix[3][3] = 1.0f;

		_inverseOrthogonalMatrix = _orthogonalMatrix.inverse();
	}

	/*
	 * Sets the _prev values for the projection variables
	void updateProjectionDirty() {
		_prevFov = fov;
		_prevFar = far;
		_prevNear = near;
		_prevWidth = cast(float)Graphics.width;
		_prevHeight = cast(float)Graphics.height;
	}
	 */
}
