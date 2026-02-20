""" 
Scenario Description 14a.
The ego-vehicle encounters a slow moving hazard blocking part of the lane. The ego-vehicle 
must brake or maneuver next to a lane of traffic moving in the opposite direction to avoid it.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town07.xodr')
param carla_map = 'Town07'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

ONCOMING_THROTTLE = 0.6
EGO_SPEED = 7
ONCOMING_CAR_SPEED = 10
DIST_THRESHOLD = 13
YIELD_THRESHOLD = 5
BLOCKING_CAR_DIST = Range(15, 20)
BREAK_INTENSITY = 0.8
BYPASS_DIST = 5
DIST_BTW_BLOCKING_ONCOMING_CARS = 10
DIST_TO_INTERSECTION = 15

behavior EgoBehavior(path):
	current_lane = network.laneAt(self)
	laneChangeCompleted = False
	bypassed = False
	try:
		do FollowLaneBehavior(EGO_SPEED, laneToFollow=current_lane)
	interrupt when (distance to blockingCar) < DIST_THRESHOLD and not laneChangeCompleted:
		if ego can see oncomingCar:
			take SetBrakeAction(BREAK_INTENSITY)
		elif (distance to oncomingCar) > YIELD_THRESHOLD:
			do LaneChangeBehavior(path, is_oppositeTraffic=True, target_speed=EGO_SPEED)
			do FollowLaneBehavior(EGO_SPEED, is_oppositeTraffic=True) until (distance to blockingCar) > BYPASS_DIST
			laneChangeCompleted = True
		else:
			wait
	interrupt when (blockingCar can see ego) and (distance to blockingCar) > BYPASS_DIST and not bypassed:
		current_laneSection = network.laneSectionAt(self)
		rightLaneSec = current_laneSection._laneToLeft
		do LaneChangeBehavior(rightLaneSec, is_oppositeTraffic=False, target_speed=EGO_SPEED)
		bypassed = True

behavior OncomingCarBehavior(path = []):
	do FollowLaneBehavior(ONCOMING_CAR_SPEED)

laneSecsWithLeftLane = []
for lane in network.lanes:
	for laneSec in lane.sections:
		if laneSec._laneToLeft is not None:
			if laneSec._laneToLeft.isForward is not laneSec.isForward:
				laneSecsWithLeftLane.append(laneSec)

assert len(laneSecsWithLeftLane) > 0, \
	'No lane sections with adjacent left lane with opposing \
	traffic direction in network.'

initLaneSec = Uniform(*laneSecsWithLeftLane)
leftLaneSec = initLaneSec._laneToLeft

spawnPt = OrientedPoint on initLaneSec.centerline
cyclistPt = OrientedPoint following roadDirection from spawnPt for 10
cyclistPt1 = OrientedPoint following roadDirection from cyclistPt for 10
cyclistPt2 = OrientedPoint following roadDirection from cyclistPt1 for 10

oppPt = OrientedPoint on leftLaneSec.centerline
oppPt1 = OrientedPoint following roadDirection from oppPt for -10
oppPt2 = OrientedPoint following roadDirection from oppPt for 10

oncomingCar = Car at oppPt,
	with behavior OncomingCarBehavior()

oncomingCar1 = Car at oppPt1,
	with behavior OncomingCarBehavior()

oncomingCar2 = Car at oppPt2,
	with behavior OncomingCarBehavior()

ego = Car at spawnPt,
	with behavior EgoBehavior(leftLaneSec)
	
cyclist = Car at cyclistPt,
	with behavior SlowCarBehavior()

cyclist1 = Car at cyclistPt1,
	with behavior SlowCarBehavior()

cyclist2 = Car at cyclistPt2,
	with behavior SlowCarBehavior()

require blockingCar can see oncomingCar
require (distance from blockingCar to oncomingCar) < DIST_BTW_BLOCKING_ONCOMING_CARS
require (distance from blockingCar to intersection) > DIST_TO_INTERSECTION